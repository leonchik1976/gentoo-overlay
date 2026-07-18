# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_13 )

inherit go-module multiprocessing n8n-task-runners-pnpm-deps python-single-r1 systemd

LAUNCHER_VERSION="1.4.7"
N8N_COMMIT="1e2d027d6d239a55fc95598179e2a25d47e78c9b"
PNPM_VERSION="10.32.1"

DESCRIPTION="Native external JavaScript and Python task runners for n8n"
HOMEPAGE="https://n8n.io/ https://github.com/n8n-io/n8n https://github.com/n8n-io/task-runner-launcher"
SRC_URI="
	https://github.com/n8n-io/n8n/archive/refs/tags/n8n%40${PV}.tar.gz
		-> ${P}-n8n-source.tar.gz
	https://github.com/n8n-io/task-runner-launcher/archive/refs/tags/${LAUNCHER_VERSION}.tar.gz
		-> ${P}-launcher-${LAUNCHER_VERSION}.tar.gz
	https://registry.npmjs.org/pnpm/-/pnpm-${PNPM_VERSION}.tgz
"
n8n_task_runners_pnpm_add_src_uri "${PV}"

EGO_SUM=(
	"github.com/creack/pty v1.1.9/go.mod"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/getsentry/sentry-go v0.35.2"
	"github.com/getsentry/sentry-go v0.35.2/go.mod"
	"github.com/go-errors/errors v1.4.2"
	"github.com/go-errors/errors v1.4.2/go.mod"
	"github.com/google/go-cmp v0.6.0"
	"github.com/google/go-cmp v0.6.0/go.mod"
	"github.com/gorilla/websocket v1.5.3"
	"github.com/gorilla/websocket v1.5.3/go.mod"
	"github.com/kr/pretty v0.3.0"
	"github.com/kr/pretty v0.3.0/go.mod"
	"github.com/kr/text v0.2.0"
	"github.com/kr/text v0.2.0/go.mod"
	"github.com/pingcap/errors v0.11.4"
	"github.com/pingcap/errors v0.11.4/go.mod"
	"github.com/pkg/errors v0.9.1"
	"github.com/pkg/errors v0.9.1/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/rogpeppe/go-internal v1.8.0"
	"github.com/rogpeppe/go-internal v1.8.0/go.mod"
	"github.com/sethvargo/go-envconfig v1.1.0"
	"github.com/sethvargo/go-envconfig v1.1.0/go.mod"
	"github.com/stretchr/testify v1.8.4"
	"github.com/stretchr/testify v1.8.4/go.mod"
	"go.uber.org/goleak v1.3.0"
	"go.uber.org/goleak v1.3.0/go.mod"
	"golang.org/x/sys v0.18.0"
	"golang.org/x/sys v0.18.0/go.mod"
	"golang.org/x/text v0.14.0"
	"golang.org/x/text v0.14.0/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c"
	"gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c/go.mod"
	"gopkg.in/yaml.v3 v3.0.1"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
)
go-module_set_globals
SRC_URI+=" ${EGO_SUM_SRC_URI}"
S="${WORKDIR}/n8n-source"

LICENSE="Sustainable-Use-1.0 n8n-Enterprise MIT Apache-2.0 BSD BSD-2 ISC 0BSD AFL-2.1 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc ${PYTHON_REQUIRED_USE}"
RESTRICT="bindist mirror"

BDEPEND="
	>=dev-lang/go-1.25.11
	>=net-libs/nodejs-24.16[npm]
	<net-libs/nodejs-25[npm]
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"
RDEPEND="
	${PYTHON_DEPS}
	~app-misc/n8n-${PV}
	acct-group/n8n-task-runners
	acct-user/n8n-task-runners
	>=net-libs/nodejs-24.16
	<net-libs/nodejs-25
	$(python_gen_cond_dep '
		~dev-python/urllib3-2.7.0[${PYTHON_USEDEP}]
		>=dev-python/websockets-15.0.1[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	local all_a=${A} file go_a old_s=${S}
	unpack "${P}-n8n-source.tar.gz" "${P}-launcher-${LAUNCHER_VERSION}.tar.gz"
	mv "n8n-n8n-${PV}" "${S}" || die
	mv "task-runner-launcher-${LAUNCHER_VERSION}" "${WORKDIR}/launcher" || die
	mkdir "${WORKDIR}/pnpm" || die
	cd "${WORKDIR}/pnpm" || die
	unpack "pnpm-${PNPM_VERSION}.tgz"
	for file in ${all_a}; do
		[[ ${file} == *%2F@v%2F*.@(mod|zip) ]] && go_a+=" ${file}"
	done
	A=${go_a}
	S="${WORKDIR}/launcher"
	go-module_src_unpack
	A=${all_a}
	S=${old_s}
}

src_prepare() {
	default
	pushd "${WORKDIR}/launcher" >/dev/null || die
	# Keep the launcher's unauthenticated health endpoint on loopback.
	eapply "${FILESDIR}/n8n-task-runners-launcher-loopback.patch"
	popd >/dev/null || die
	sha256sum pnpm-lock.yaml > "${T}/pnpm-lock.sha256" || die
}

runner_pnpm() {
	node "${WORKDIR}/pnpm/package/bin/pnpm.cjs" "$@" || die
}

replace_literal() {
	local file=${1} old=${2} new=${3}
	grep -Fq -- "${old}" "${file}" ||
		die "expected text is missing from ${file}: ${old}"
	"${PYTHON}" "${FILESDIR}/n8n-task-runners-replace-literal.py" \
		"${file}" "${old}" "${new}" ||
		die "failed to update ${file}"
	grep -Fq -- "${new}" "${file}" ||
		die "replacement is missing from ${file}: ${new}"
}

src_configure() {
	local store="${T}/pnpm-store" entry filename index
	local package_id prefix target tarball_id i
	local -a batch=()
	go-module_src_configure
	python_setup
	"${PYTHON}" -c 'import yaml' || die "${PYTHON} cannot import yaml"
	mkdir -p "${store}" || die
	for entry in "${N8N_TASK_RUNNERS_PNPM_SRC_URI[@]}"; do
		filename=${entry##* -> }
		batch+=( "${DISTDIR}/${filename}" )
		if (( ${#batch[@]} == 100 )); then
			runner_pnpm store add --store-dir "${store}" "${batch[@]}"
			batch=()
		fi
	done
	(( ${#batch[@]} )) && runner_pnpm store add --store-dir "${store}" "${batch[@]}"
	for (( i = 0; i < ${#N8N_TASK_RUNNERS_PNPM_SRC_URI[@]}; i++ )); do
		entry=${N8N_TASK_RUNNERS_PNPM_SRC_URI[i]}
		filename=${entry##* -> }
		index=$(find "${store}/v10/index" -type f -name "*-file+..+..+distdir+${filename}.json" -print -quit) || die
		[[ -n ${index} ]] || die "no pnpm store index for ${filename}"
		prefix=${index%%-file+*}
		package_id=${N8N_TASK_RUNNERS_PNPM_PACKAGE_IDS[i]}
		package_id=${package_id//\//+}; package_id=${package_id//:/+}
		ln -f "${index}" "${prefix}-${package_id}.json" || die
		if [[ ${N8N_TASK_RUNNERS_PNPM_PACKAGE_IDS[i]} == *@https://* ]]; then
			for target in "${package_id}" "${entry%% -> *}"; do
				target=${target//\//+}; target=${target//:/+}; target=${target//#/+}
				mkdir -p "${store}/v10/${target}" || die
				ln -f "${index}" "${store}/v10/${target}/integrity.json" || die
				ln -f "${index}" "${store}/v10/${target}/integrity-not-built.json" || die
			done
		fi
	done
	export CI=true npm_config_offline=true npm_config_store_dir="${store}"
	export npm_config_cache="${T}/npm-cache" PNPM_HOME="${T}/pnpm-home" COREPACK_HOME="${T}/corepack"
	"${PYTHON}" "${FILESDIR}/n8n-task-runners-create-pnpm-metadata.py" \
		pnpm-lock.yaml "${T%/temp}/homedir/.cache/pnpm" || die
	runner_pnpm install --filter '@n8n/task-runner...' --frozen-lockfile --offline --ignore-scripts --store-dir "${store}"
	sha256sum --check "${T}/pnpm-lock.sha256" || die "pnpm modified pnpm-lock.yaml"
}

src_compile() {
	local deploy="${WORKDIR}/javascript" isolated_deploy jobs manifest native_addon node_gyp npm_root
	local venv="${WORKDIR}/python/.venv" purelib runtime_addon
	export CI=true NODE_ENV=production DOCKER_BUILD=true npm_config_offline=true
	export NODE_OPTIONS="--max-old-space-size=7168"
	export npm_config_store_dir="${T}/pnpm-store" npm_config_cache="${T}/npm-cache"
	export PNPM_HOME="${T}/pnpm-home" COREPACK_HOME="${T}/corepack"
	export PATH="${WORKDIR}/pnpm/package/bin:${PATH}"
	ln -sf pnpm.cjs "${WORKDIR}/pnpm/package/bin/pnpm" || die
	runner_pnpm --filter '@n8n/task-runner...' run build
	replace_literal packages/nodes-base/package.json \
		"https://cdn.sheetjs.com/xlsx-0.20.2/xlsx-0.20.2.tgz" \
		"file:${DISTDIR}/${N8N_TASK_RUNNERS_XLSX_DISTFILE}"
	replace_literal packages/@n8n/instance-ai/package.json \
		"https://cdn.sheetjs.com/xlsx-0.20.2/xlsx-0.20.2.tgz" \
		"file:${DISTDIR}/${N8N_TASK_RUNNERS_XLSX_DISTFILE}"
	replace_literal packages/frontend/editor-ui/package.json \
		"github:rhashimoto/wa-sqlite#779219540f66cecaa159da32b3b8936697ba10a7" \
		"file:${DISTDIR}/${N8N_TASK_RUNNERS_WA_SQLITE_DISTFILE}"
	while IFS= read -r -d '' manifest; do
		if grep -Fq \
			-e "https://cdn.sheetjs.com/xlsx-0.20.2/xlsx-0.20.2.tgz" \
			-e "github:rhashimoto/wa-sqlite#779219540f66cecaa159da32b3b8936697ba10a7" \
			"${manifest}"; then
			die "unreplaced direct dependency in ${manifest}"
		fi
	done < <(find packages -name package.json -print0)
	"${PYTHON}" "${FILESDIR}/n8n-task-runners-create-pnpm-metadata.py" \
		pnpm-lock.yaml "${T%/temp}/homedir/.cache/pnpm" || die
	runner_pnpm --filter=@n8n/task-runner --prod --legacy deploy --no-optional "${deploy}"
	mkdir -p "${deploy}/node_modules/moment" || die
	tar -xzf "${DISTDIR}/${N8N_TASK_RUNNERS_MOMENT_DISTFILE}" \
		--strip-components=1 -C "${deploy}/node_modules/moment" || die
	isolated_deploy=$(find "${deploy}/node_modules/.pnpm" -type d \
		-path '*/isolated-vm@6.1.2/node_modules/isolated-vm' -print -quit) || die
	[[ -n ${isolated_deploy} ]] || die "deployed isolated-vm package is missing"
	rm -rf "${isolated_deploy}/prebuilds" || die
	pushd "${isolated_deploy}" >/dev/null || die
	eapply "${FILESDIR}/isolated-vm-6.1.2-cstdint.patch"
	popd >/dev/null || die
	npm_root=$(npm root --global) || die
	node_gyp=${npm_root}/npm/node_modules/node-gyp/bin/node-gyp.js
	[[ -f ${node_gyp} ]] || die "npm did not provide node-gyp"
	jobs=$(get_makeopts_jobs)
	export npm_config_build_from_source=true npm_config_nodedir=/usr
	pushd "${isolated_deploy}" >/dev/null || die
	node "${node_gyp}" rebuild --release -j "${jobs}" || die
	popd >/dev/null || die
	runtime_addon="${isolated_deploy}/build/Release/isolated_vm.node"
	[[ -f ${runtime_addon} ]] || die "source-built isolated-vm addon is missing"
	cp "${runtime_addon}" "${T}/isolated_vm.node" || die
	rm -rf "${isolated_deploy}/build" || die
	mkdir -p "${isolated_deploy}/build/Release" || die
	mv "${T}/isolated_vm.node" "${runtime_addon}" || die
	# Sentry's profiler and native stacktrace addons are optional accelerators.
	find "${deploy}" -type f -path '*/@sentry-internal/node-cpu-profiler/lib/*.node' -delete || die
	find "${deploy}" -type f -path '*/@sentry-internal/node-native-stacktrace/lib/*.node' -delete || die
	native_addon=$(find "${deploy}" -type f -name '*.node' -print -quit) || die
	[[ ${native_addon} == ${runtime_addon} ]] ||
		die "unexpected native addon in JavaScript runner: ${native_addon}"
	[[ $(find "${deploy}" -type f -name '*.node' | wc -l) -eq 1 ]] ||
		die "JavaScript runner contains more than one native addon"
	find "${deploy}" -type f -path '*/ssh2/util/pagent.exe' -delete || die
	python_setup
	"${PYTHON}" -m venv --without-pip --system-site-packages "${venv}" || die
	purelib=$("${venv}/bin/python" -c 'import sysconfig; print(sysconfig.get_path("purelib"))') || die
	cp -a packages/@n8n/task-runner-python/src "${purelib}/" || die
	pushd "${WORKDIR}/launcher" >/dev/null || die
	ego build -trimpath -o "${WORKDIR}/task-runner-launcher" ./cmd/launcher
	popd >/dev/null || die
	sha256sum --check "${T}/pnpm-lock.sha256" || die "build modified pnpm-lock.yaml"
}

src_install() {
	insinto /usr/libexec/n8n-task-runners/javascript
	doins -r "${WORKDIR}/javascript"/.
	insinto /usr/libexec/n8n-task-runners/python
	doins -r "${WORKDIR}/python"/.
	exeinto /usr/libexec/n8n-task-runners
	doexe "${WORKDIR}/task-runner-launcher"
	insinto /etc
	doins "${FILESDIR}/n8n-task-runners.json"
	doins "${FILESDIR}/n8n-task-runners.env"
	fperms 0600 /etc/n8n-task-runners.env
	newinitd "${FILESDIR}/n8n-task-runners.initd" n8n-task-runners
	newconfd "${FILESDIR}/n8n-task-runners.confd" n8n-task-runners
	fperms 0600 /etc/conf.d/n8n-task-runners
	insinto /etc/logrotate.d
	newins "${FILESDIR}/n8n-task-runners.logrotate" n8n-task-runners
	systemd_dounit "${FILESDIR}/n8n-task-runners.service"
	dodoc "${FILESDIR}/README.gentoo"
}

pkg_postinst() {
	ewarn "Set the same strong N8N_RUNNERS_AUTH_TOKEN for n8n and its task runners."
	einfo "Read /usr/share/doc/${PF}/README.gentoo* before enabling either service."
	einfo "Neither service is enabled or started automatically."
}
