# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit check-reqs multiprocessing n8n-pnpm-deps python-any-r1 systemd wrapper

N8N_TAG="n8n@${PV}"
N8N_COMMIT="1e2d027d6d239a55fc95598179e2a25d47e78c9b"
PNPM_VERSION="10.32.1"

DESCRIPTION="Extensible workflow automation platform"
HOMEPAGE="https://n8n.io/ https://github.com/n8n-io/n8n"
SRC_URI="
	https://github.com/n8n-io/n8n/archive/refs/tags/${N8N_TAG}.tar.gz
		-> ${P}-source.tar.gz
	https://registry.npmjs.org/pnpm/-/pnpm-${PNPM_VERSION}.tgz
	https://github.com/n8n-io/n8n/releases/download/n8n%40${PV}/THIRD_PARTY_LICENSES.md
		-> ${P}-THIRD_PARTY_LICENSES.md
"
n8n_pnpm_deps_add_src_uri "${PV}"
S="${WORKDIR}/source"

LICENSE="Sustainable-Use-1.0 n8n-Enterprise"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

RESTRICT="bindist mirror"

CHECKREQS_DISK_BUILD="15G"
CHECKREQS_DISK_USR="2G"

QA_PREBUILT="
	usr/libexec/n8n/node_modules/.pnpm/agent-browser@0.26.0/node_modules/agent-browser/bin/agent-browser-linux-arm64
	usr/libexec/n8n/node_modules/.pnpm/agent-browser@0.26.0/node_modules/agent-browser/bin/agent-browser-linux-x64
"

BDEPEND="
	>=net-libs/nodejs-22.22[npm]
	<net-libs/nodejs-25[npm]
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"
RDEPEND="
	>=net-libs/nodejs-22.22
	<net-libs/nodejs-25
	acct-group/n8n
	acct-user/n8n
	sys-apps/ripgrep
"

PATCHES=(
	"${FILESDIR}/${P}-system-ripgrep.patch"
	"${FILESDIR}/${P}-offline-direct-deps.patch"
)

python_check_deps() {
	python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	check-reqs_pkg_pretend
}

pkg_setup() {
	check-reqs_pkg_setup
	python-any-r1_pkg_setup
}

src_unpack() {
	unpack "${P}-source.tar.gz"
	mv "n8n-n8n-${PV}" "${S}" || die

	mkdir "${WORKDIR}/pnpm" || die
	cd "${WORKDIR}/pnpm" || die
	unpack "pnpm-${PNPM_VERSION}.tgz"
}

src_prepare() {
	default
	sha256sum pnpm-lock.yaml > "${T}/pnpm-lock.sha256" || die
}

n8n_pnpm() {
	node "${WORKDIR}/pnpm/package/bin/pnpm.cjs" "$@" || die
}

src_configure() {
	local store="${T}/pnpm-store"
	local -a batch=()
	local entry filename index prefix package_id target tarball_id
	local i jobs node_gyp npm_root parcel_dir isolated_dir sqlite_dir

	einfo "Building with $(node --version)"
	python_setup
	"${PYTHON}" -c 'import yaml' || die "${PYTHON} cannot import yaml"
	mkdir -p "${store}" || die
	for entry in "${N8N_PNPM_SRC_URI[@]}"; do
		filename=${entry##* -> }
		batch+=( "${DISTDIR}/${filename}" )
		if (( ${#batch[@]} == 100 )); then
			n8n_pnpm store add --store-dir "${store}" "${batch[@]}"
			batch=()
		fi
	done
	if (( ${#batch[@]} )); then
		n8n_pnpm store add --store-dir "${store}" "${batch[@]}"
	fi

	# `pnpm store add` indexes a local tarball by its file locator. Add the
	# equivalent locked registry locator without duplicating package contents.
	for (( i = 0; i < ${#N8N_PNPM_SRC_URI[@]}; i++ )); do
		entry=${N8N_PNPM_SRC_URI[i]}
		filename=${entry##* -> }
		index=$(find "${store}/v10/index" -type f \
			-name "*-file+..+..+distdir+${filename}.json" -print -quit) || die
		[[ -n ${index} ]] || die "no pnpm store index for ${filename}"
		prefix=${index%%-file+*}
		package_id=${N8N_PNPM_PACKAGE_IDS[i]}
		package_id=${package_id//\//+}
		package_id=${package_id//:/+}
		ln -f "${index}" "${prefix}-${package_id}.json" || die
		if [[ ${N8N_PNPM_PACKAGE_IDS[i]} == *@https://* ]]; then
			target=${store}/v10/${package_id//#/+}
			mkdir -p "${target}" || die
			ln -f "${index}" "${target}/integrity.json" || die
			ln -f "${index}" "${target}/integrity-not-built.json" || die
			tarball_id=${entry%% -> *}
			tarball_id=${tarball_id//\//+}
			tarball_id=${tarball_id//:/+}
			target=${store}/v10/${tarball_id//#/+}
			mkdir -p "${target}" || die
			ln -f "${index}" "${target}/integrity.json" || die
			ln -f "${index}" "${target}/integrity-not-built.json" || die
		fi
	done

	export CI=true
	export npm_config_build_from_source=true
	export npm_config_nodedir
	npm_config_nodedir=$(dirname "$(dirname "$(command -v node)")") || die
	export npm_config_offline=true
	export PNPM_HOME="${T}/pnpm-home"
	export COREPACK_HOME="${T}/corepack"
	export npm_config_cache="${T}/npm-cache"
	export npm_config_store_dir="${store}"
	"${PYTHON}" "${FILESDIR}/n8n-create-pnpm-metadata.py" pnpm-lock.yaml \
		"${DISTDIR}" "${T%/temp}/homedir/.cache/pnpm" || die

	n8n_pnpm install --frozen-lockfile --offline --ignore-scripts \
		--store-dir "${store}"

	npm_root=$(npm root --global) || die
	node_gyp=${npm_root}/npm/node_modules/node-gyp/bin/node-gyp.js
	[[ -f ${node_gyp} ]] || die "npm did not provide node-gyp"
	jobs=$(get_makeopts_jobs)
	isolated_dir=node_modules/.pnpm/isolated-vm@6.1.2/node_modules/isolated-vm
	sqlite_dir=node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3
	parcel_dir=node_modules/.pnpm/@parcel+watcher@2.5.1/node_modules/@parcel/watcher

	if [[ -d ${isolated_dir}/prebuilds ]]; then
		rm -r "${isolated_dir}/prebuilds" || die
	fi
	pushd "${isolated_dir}" >/dev/null || die
	eapply "${FILESDIR}/isolated-vm-6.1.2-cstdint.patch"
	popd >/dev/null || die
	(
		cd "${isolated_dir}" || die
		node "${node_gyp}" rebuild --release -j "${jobs}" || die
	) || die
	(
		cd "${sqlite_dir}" || die
		node "${node_gyp}" rebuild --release -j "${jobs}" || die
	) || die
	(
		cd "${parcel_dir}" || die
		node "${node_gyp}" rebuild --release -j "${jobs}" || die
	) || die
	sha256sum --check "${T}/pnpm-lock.sha256" || die "pnpm modified pnpm-lock.yaml"
}

src_compile() {
	local addon agent_binary package package_name pattern source_native target
	local -a deployed=()
	python_setup
	export CI=true
	export npm_config_build_from_source=true
	export npm_config_nodedir
	npm_config_nodedir=$(dirname "$(dirname "$(command -v node)")") || die
	export npm_config_offline=true
	export PNPM_HOME="${T}/pnpm-home"
	export COREPACK_HOME="${T}/corepack"
	export npm_config_cache="${T}/npm-cache"
	export npm_config_store_dir="${T}/pnpm-store"
	export N8N_XLSX_DISTFILE="${DISTDIR}/n8n-pnpm-xlsx-0.20.2.tgz"
	export N8N_PNPM_METADATA_HELPER="${FILESDIR}/n8n-create-pnpm-metadata.py"
	export N8N_PYTHON="${PYTHON}"
	export N8N_DISTDIR="${DISTDIR}"
	export PATH="${WORKDIR}/pnpm/package/bin:${PATH}"

	ln -sf pnpm.cjs "${WORKDIR}/pnpm/package/bin/pnpm" || die
	./scripts/build-n8n.mjs || die
	for package in isolated-vm@6.1.2 sqlite3@5.1.7 @parcel+watcher@2.5.1; do
		case ${package} in
			isolated-vm*)
				package_name=isolated-vm
				pattern='isolated-vm@6.1.2*'
				addon=isolated_vm.node
				;;
			sqlite3*)
				package_name=sqlite3
				pattern='sqlite3@5.1.7*'
				addon=node_sqlite3.node
				;;
			@parcel*)
				package_name=@parcel/watcher
				pattern='@parcel+watcher@2.5.1*'
				addon=watcher.node
				;;
		esac
		source_native=node_modules/.pnpm/${package}/node_modules/${package_name}
		mapfile -d '' deployed < <(find compiled/node_modules/.pnpm -mindepth 1 \
			-maxdepth 1 -type d -name "${pattern}" -print0)
		(( ${#deployed[@]} )) || die "deployed ${package_name} package not found"
		for target in "${deployed[@]}"; do
			target+=/node_modules/${package_name}/build/Release
			mkdir -p "${target}" || die
			cp -a "${source_native}/build/Release/${addon}" "${target}/" || die
		done
	done

	# The three addons above are compiled locally.  Do not ship restored
	# upstream prebuild matrices or native build intermediates.
	rm -rf compiled/node_modules/.pnpm/isolated-vm@6.1.2/node_modules/isolated-vm/prebuilds || die

	# Sentry's profiler and native stacktrace acceleration are optional.  The
	# JavaScript SDK degrades gracefully when these addons are unavailable.
	find compiled/node_modules/.pnpm \
		-path '*/@sentry-internal/node-cpu-profiler/lib/*.node' -delete || die
	find compiled/node_modules/.pnpm \
		-path '*/@sentry-internal/node-native-stacktrace/lib/*.node' -delete || die

	# node-oracledb uses its pure-JavaScript Thin mode by default.  Its bundled
	# addon matrix is only needed after an explicit initOracleClient() call.
	find compiled/node_modules/.pnpm -type d \
		-path '*/oracledb/build/Release' -prune -exec rm -rf {} + || die

	# Selenium Manager is not invoked by n8n's normal service operation.  Users
	# of Selenium-based optional tooling must provide browser drivers themselves.
	find compiled/node_modules/.pnpm -type d \
		-path '*/selenium-webdriver/bin' -prune -exec rm -rf {} + || die

	# ssh2 ships a Windows-only PuTTY pageant helper in otherwise portable
	# package data. It is never selected by its Linux agent implementation.
	find compiled/node_modules/.pnpm -type f \
		-path '*/ssh2@*/node_modules/ssh2/util/pagent.exe' -delete || die

	# agent-browser is a runtime tool used by browser-agent workflows.  Its npm
	# release has binaries but no Rust source.  Retain only this glibc system's
	# architecture; all foreign, musl, macOS, and Windows binaries are removed.
	case ${ARCH} in
		amd64) agent_binary=agent-browser-linux-x64 ;;
		arm64) agent_binary=agent-browser-linux-arm64 ;;
		*) die "unsupported architecture: ${ARCH}" ;;
	esac
	find compiled/node_modules/.pnpm -type f \
		-path '*/agent-browser/bin/agent-browser-*' \
		! -name "${agent_binary}" -delete || die
	[[ -f compiled/node_modules/.pnpm/agent-browser@0.26.0/node_modules/agent-browser/bin/${agent_binary} ]] ||
		die "missing ${agent_binary}"

	rm -f compiled/build-manifest.json || die
	sha256sum --check "${T}/pnpm-lock.sha256" || die "build modified pnpm-lock.yaml"

	# The deployed closure is self-contained. Release the workspace dependency
	# tree and private caches before Portage creates its image tree; retaining
	# them can exhaust inodes on large tmpfs builds during src_install.
	rm -rf node_modules "${T}/pnpm-store" "${T}/npm-cache" \
		"${T%/temp}/homedir/.cache/pnpm" || die
}

src_install() {
	local agent_binary
	insinto /usr/libexec/n8n
	doins -r compiled/.
	fperms 0755 /usr/libexec/n8n/bin/n8n
	case ${ARCH} in
		amd64) agent_binary=agent-browser-linux-x64 ;;
		arm64) agent_binary=agent-browser-linux-arm64 ;;
	esac
	fperms 0755 "/usr/libexec/n8n/node_modules/.pnpm/agent-browser@0.26.0/node_modules/agent-browser/bin/${agent_binary}"
	make_wrapper n8n /usr/libexec/n8n/bin/n8n

	newinitd "${FILESDIR}/n8n.initd" n8n
	newconfd "${FILESDIR}/n8n.confd" n8n
	fperms 0600 /etc/conf.d/n8n
	systemd_dounit "${FILESDIR}/n8n.service"

	dodoc README.md "${FILESDIR}/README.gentoo"
	newdoc "${DISTDIR}/${P}-THIRD_PARTY_LICENSES.md" THIRD_PARTY_LICENSES.md
	dodoc LICENSE.md LICENSE_EE.md
}

pkg_postinst() {
	einfo "For OpenRC, review /etc/conf.d/n8n before starting the service."
	einfo "For systemd, use 'systemctl edit n8n' to configure environment overrides."
	einfo "Set and retain a stable N8N_ENCRYPTION_KEY for production use."
	einfo "Neither service is enabled or started automatically."
}
