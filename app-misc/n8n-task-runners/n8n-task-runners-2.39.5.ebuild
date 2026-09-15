# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..15} )

inherit go-module multiprocessing n8n-task-runners-pnpm-deps-2.39.5 python-single-r1 systemd

LAUNCHER_VERSION="1.4.7"
PNPM_VERSION="11.25.0"

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

# Direct upstream proxy artifacts keep the loopback-patched launcher build
# offline without deprecated EGO_SUM or a maintainer-hosted dependency tarball.
LAUNCHER_GO_PROXY_FILES=(
	"github.com/creack/pty/@v/v1.1.9.mod|n8n-launcher-1.4.7-0.mod"
	"github.com/creack/pty/@v/v1.1.9.zip|n8n-launcher-1.4.7-0.zip"
	"github.com/creack/pty/@v/v1.1.9.info|n8n-launcher-1.4.7-0.info"
	"github.com/davecgh/go-spew/@v/v1.1.1.mod|n8n-launcher-1.4.7-1.mod"
	"github.com/davecgh/go-spew/@v/v1.1.1.zip|n8n-launcher-1.4.7-1.zip"
	"github.com/davecgh/go-spew/@v/v1.1.1.info|n8n-launcher-1.4.7-1.info"
	"github.com/getsentry/sentry-go/@v/v0.35.2.mod|n8n-launcher-1.4.7-2.mod"
	"github.com/getsentry/sentry-go/@v/v0.35.2.zip|n8n-launcher-1.4.7-2.zip"
	"github.com/getsentry/sentry-go/@v/v0.35.2.info|n8n-launcher-1.4.7-2.info"
	"github.com/go-errors/errors/@v/v1.4.2.mod|n8n-launcher-1.4.7-3.mod"
	"github.com/go-errors/errors/@v/v1.4.2.zip|n8n-launcher-1.4.7-3.zip"
	"github.com/go-errors/errors/@v/v1.4.2.info|n8n-launcher-1.4.7-3.info"
	"github.com/google/go-cmp/@v/v0.6.0.mod|n8n-launcher-1.4.7-4.mod"
	"github.com/google/go-cmp/@v/v0.6.0.zip|n8n-launcher-1.4.7-4.zip"
	"github.com/google/go-cmp/@v/v0.6.0.info|n8n-launcher-1.4.7-4.info"
	"github.com/gorilla/websocket/@v/v1.5.3.mod|n8n-launcher-1.4.7-5.mod"
	"github.com/gorilla/websocket/@v/v1.5.3.zip|n8n-launcher-1.4.7-5.zip"
	"github.com/gorilla/websocket/@v/v1.5.3.info|n8n-launcher-1.4.7-5.info"
	"github.com/kr/pretty/@v/v0.3.0.mod|n8n-launcher-1.4.7-6.mod"
	"github.com/kr/pretty/@v/v0.3.0.zip|n8n-launcher-1.4.7-6.zip"
	"github.com/kr/pretty/@v/v0.3.0.info|n8n-launcher-1.4.7-6.info"
	"github.com/kr/text/@v/v0.2.0.mod|n8n-launcher-1.4.7-7.mod"
	"github.com/kr/text/@v/v0.2.0.zip|n8n-launcher-1.4.7-7.zip"
	"github.com/kr/text/@v/v0.2.0.info|n8n-launcher-1.4.7-7.info"
	"github.com/pingcap/errors/@v/v0.11.4.mod|n8n-launcher-1.4.7-8.mod"
	"github.com/pingcap/errors/@v/v0.11.4.zip|n8n-launcher-1.4.7-8.zip"
	"github.com/pingcap/errors/@v/v0.11.4.info|n8n-launcher-1.4.7-8.info"
	"github.com/pkg/errors/@v/v0.9.1.mod|n8n-launcher-1.4.7-9.mod"
	"github.com/pkg/errors/@v/v0.9.1.zip|n8n-launcher-1.4.7-9.zip"
	"github.com/pkg/errors/@v/v0.9.1.info|n8n-launcher-1.4.7-9.info"
	"github.com/pmezard/go-difflib/@v/v1.0.0.mod|n8n-launcher-1.4.7-10.mod"
	"github.com/pmezard/go-difflib/@v/v1.0.0.zip|n8n-launcher-1.4.7-10.zip"
	"github.com/pmezard/go-difflib/@v/v1.0.0.info|n8n-launcher-1.4.7-10.info"
	"github.com/rogpeppe/go-internal/@v/v1.8.0.mod|n8n-launcher-1.4.7-11.mod"
	"github.com/rogpeppe/go-internal/@v/v1.8.0.zip|n8n-launcher-1.4.7-11.zip"
	"github.com/rogpeppe/go-internal/@v/v1.8.0.info|n8n-launcher-1.4.7-11.info"
	"github.com/sethvargo/go-envconfig/@v/v1.1.0.mod|n8n-launcher-1.4.7-12.mod"
	"github.com/sethvargo/go-envconfig/@v/v1.1.0.zip|n8n-launcher-1.4.7-12.zip"
	"github.com/sethvargo/go-envconfig/@v/v1.1.0.info|n8n-launcher-1.4.7-12.info"
	"github.com/stretchr/testify/@v/v1.8.4.mod|n8n-launcher-1.4.7-13.mod"
	"github.com/stretchr/testify/@v/v1.8.4.zip|n8n-launcher-1.4.7-13.zip"
	"github.com/stretchr/testify/@v/v1.8.4.info|n8n-launcher-1.4.7-13.info"
	"go.uber.org/goleak/@v/v1.3.0.mod|n8n-launcher-1.4.7-14.mod"
	"go.uber.org/goleak/@v/v1.3.0.zip|n8n-launcher-1.4.7-14.zip"
	"go.uber.org/goleak/@v/v1.3.0.info|n8n-launcher-1.4.7-14.info"
	"golang.org/x/sys/@v/v0.18.0.mod|n8n-launcher-1.4.7-15.mod"
	"golang.org/x/sys/@v/v0.18.0.zip|n8n-launcher-1.4.7-15.zip"
	"golang.org/x/sys/@v/v0.18.0.info|n8n-launcher-1.4.7-15.info"
	"golang.org/x/text/@v/v0.14.0.mod|n8n-launcher-1.4.7-16.mod"
	"golang.org/x/text/@v/v0.14.0.zip|n8n-launcher-1.4.7-16.zip"
	"golang.org/x/text/@v/v0.14.0.info|n8n-launcher-1.4.7-16.info"
	"gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.mod|n8n-launcher-1.4.7-17.mod"
	"gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.zip|n8n-launcher-1.4.7-17.zip"
	"gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.info|n8n-launcher-1.4.7-17.info"
	"gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.mod|n8n-launcher-1.4.7-18.mod"
	"gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.zip|n8n-launcher-1.4.7-18.zip"
	"gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.info|n8n-launcher-1.4.7-18.info"
	"gopkg.in/yaml.v3/@v/v3.0.1.mod|n8n-launcher-1.4.7-19.mod"
	"gopkg.in/yaml.v3/@v/v3.0.1.zip|n8n-launcher-1.4.7-19.zip"
	"gopkg.in/yaml.v3/@v/v3.0.1.info|n8n-launcher-1.4.7-19.info"
)
SRC_URI+="
	https://proxy.golang.org/github.com/creack/pty/@v/v1.1.9.mod
		-> n8n-launcher-1.4.7-0.mod
	https://proxy.golang.org/github.com/creack/pty/@v/v1.1.9.zip
		-> n8n-launcher-1.4.7-0.zip
	https://proxy.golang.org/github.com/creack/pty/@v/v1.1.9.info
		-> n8n-launcher-1.4.7-0.info
	https://proxy.golang.org/github.com/davecgh/go-spew/@v/v1.1.1.mod
		-> n8n-launcher-1.4.7-1.mod
	https://proxy.golang.org/github.com/davecgh/go-spew/@v/v1.1.1.zip
		-> n8n-launcher-1.4.7-1.zip
	https://proxy.golang.org/github.com/davecgh/go-spew/@v/v1.1.1.info
		-> n8n-launcher-1.4.7-1.info
	https://proxy.golang.org/github.com/getsentry/sentry-go/@v/v0.35.2.mod
		-> n8n-launcher-1.4.7-2.mod
	https://proxy.golang.org/github.com/getsentry/sentry-go/@v/v0.35.2.zip
		-> n8n-launcher-1.4.7-2.zip
	https://proxy.golang.org/github.com/getsentry/sentry-go/@v/v0.35.2.info
		-> n8n-launcher-1.4.7-2.info
	https://proxy.golang.org/github.com/go-errors/errors/@v/v1.4.2.mod
		-> n8n-launcher-1.4.7-3.mod
	https://proxy.golang.org/github.com/go-errors/errors/@v/v1.4.2.zip
		-> n8n-launcher-1.4.7-3.zip
	https://proxy.golang.org/github.com/go-errors/errors/@v/v1.4.2.info
		-> n8n-launcher-1.4.7-3.info
	https://proxy.golang.org/github.com/google/go-cmp/@v/v0.6.0.mod
		-> n8n-launcher-1.4.7-4.mod
	https://proxy.golang.org/github.com/google/go-cmp/@v/v0.6.0.zip
		-> n8n-launcher-1.4.7-4.zip
	https://proxy.golang.org/github.com/google/go-cmp/@v/v0.6.0.info
		-> n8n-launcher-1.4.7-4.info
	https://proxy.golang.org/github.com/gorilla/websocket/@v/v1.5.3.mod
		-> n8n-launcher-1.4.7-5.mod
	https://proxy.golang.org/github.com/gorilla/websocket/@v/v1.5.3.zip
		-> n8n-launcher-1.4.7-5.zip
	https://proxy.golang.org/github.com/gorilla/websocket/@v/v1.5.3.info
		-> n8n-launcher-1.4.7-5.info
	https://proxy.golang.org/github.com/kr/pretty/@v/v0.3.0.mod
		-> n8n-launcher-1.4.7-6.mod
	https://proxy.golang.org/github.com/kr/pretty/@v/v0.3.0.zip
		-> n8n-launcher-1.4.7-6.zip
	https://proxy.golang.org/github.com/kr/pretty/@v/v0.3.0.info
		-> n8n-launcher-1.4.7-6.info
	https://proxy.golang.org/github.com/kr/text/@v/v0.2.0.mod
		-> n8n-launcher-1.4.7-7.mod
	https://proxy.golang.org/github.com/kr/text/@v/v0.2.0.zip
		-> n8n-launcher-1.4.7-7.zip
	https://proxy.golang.org/github.com/kr/text/@v/v0.2.0.info
		-> n8n-launcher-1.4.7-7.info
	https://proxy.golang.org/github.com/pingcap/errors/@v/v0.11.4.mod
		-> n8n-launcher-1.4.7-8.mod
	https://proxy.golang.org/github.com/pingcap/errors/@v/v0.11.4.zip
		-> n8n-launcher-1.4.7-8.zip
	https://proxy.golang.org/github.com/pingcap/errors/@v/v0.11.4.info
		-> n8n-launcher-1.4.7-8.info
	https://proxy.golang.org/github.com/pkg/errors/@v/v0.9.1.mod
		-> n8n-launcher-1.4.7-9.mod
	https://proxy.golang.org/github.com/pkg/errors/@v/v0.9.1.zip
		-> n8n-launcher-1.4.7-9.zip
	https://proxy.golang.org/github.com/pkg/errors/@v/v0.9.1.info
		-> n8n-launcher-1.4.7-9.info
	https://proxy.golang.org/github.com/pmezard/go-difflib/@v/v1.0.0.mod
		-> n8n-launcher-1.4.7-10.mod
	https://proxy.golang.org/github.com/pmezard/go-difflib/@v/v1.0.0.zip
		-> n8n-launcher-1.4.7-10.zip
	https://proxy.golang.org/github.com/pmezard/go-difflib/@v/v1.0.0.info
		-> n8n-launcher-1.4.7-10.info
	https://proxy.golang.org/github.com/rogpeppe/go-internal/@v/v1.8.0.mod
		-> n8n-launcher-1.4.7-11.mod
	https://proxy.golang.org/github.com/rogpeppe/go-internal/@v/v1.8.0.zip
		-> n8n-launcher-1.4.7-11.zip
	https://proxy.golang.org/github.com/rogpeppe/go-internal/@v/v1.8.0.info
		-> n8n-launcher-1.4.7-11.info
	https://proxy.golang.org/github.com/sethvargo/go-envconfig/@v/v1.1.0.mod
		-> n8n-launcher-1.4.7-12.mod
	https://proxy.golang.org/github.com/sethvargo/go-envconfig/@v/v1.1.0.zip
		-> n8n-launcher-1.4.7-12.zip
	https://proxy.golang.org/github.com/sethvargo/go-envconfig/@v/v1.1.0.info
		-> n8n-launcher-1.4.7-12.info
	https://proxy.golang.org/github.com/stretchr/testify/@v/v1.8.4.mod
		-> n8n-launcher-1.4.7-13.mod
	https://proxy.golang.org/github.com/stretchr/testify/@v/v1.8.4.zip
		-> n8n-launcher-1.4.7-13.zip
	https://proxy.golang.org/github.com/stretchr/testify/@v/v1.8.4.info
		-> n8n-launcher-1.4.7-13.info
	https://proxy.golang.org/go.uber.org/goleak/@v/v1.3.0.mod
		-> n8n-launcher-1.4.7-14.mod
	https://proxy.golang.org/go.uber.org/goleak/@v/v1.3.0.zip
		-> n8n-launcher-1.4.7-14.zip
	https://proxy.golang.org/go.uber.org/goleak/@v/v1.3.0.info
		-> n8n-launcher-1.4.7-14.info
	https://proxy.golang.org/golang.org/x/sys/@v/v0.18.0.mod
		-> n8n-launcher-1.4.7-15.mod
	https://proxy.golang.org/golang.org/x/sys/@v/v0.18.0.zip
		-> n8n-launcher-1.4.7-15.zip
	https://proxy.golang.org/golang.org/x/sys/@v/v0.18.0.info
		-> n8n-launcher-1.4.7-15.info
	https://proxy.golang.org/golang.org/x/text/@v/v0.14.0.mod
		-> n8n-launcher-1.4.7-16.mod
	https://proxy.golang.org/golang.org/x/text/@v/v0.14.0.zip
		-> n8n-launcher-1.4.7-16.zip
	https://proxy.golang.org/golang.org/x/text/@v/v0.14.0.info
		-> n8n-launcher-1.4.7-16.info
	https://proxy.golang.org/gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.mod
		-> n8n-launcher-1.4.7-17.mod
	https://proxy.golang.org/gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.zip
		-> n8n-launcher-1.4.7-17.zip
	https://proxy.golang.org/gopkg.in/check.v1/@v/v0.0.0-20161208181325-20d25e280405.info
		-> n8n-launcher-1.4.7-17.info
	https://proxy.golang.org/gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.mod
		-> n8n-launcher-1.4.7-18.mod
	https://proxy.golang.org/gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.zip
		-> n8n-launcher-1.4.7-18.zip
	https://proxy.golang.org/gopkg.in/check.v1/@v/v1.0.0-20201130134442-10cb98267c6c.info
		-> n8n-launcher-1.4.7-18.info
	https://proxy.golang.org/gopkg.in/yaml.v3/@v/v3.0.1.mod
		-> n8n-launcher-1.4.7-19.mod
	https://proxy.golang.org/gopkg.in/yaml.v3/@v/v3.0.1.zip
		-> n8n-launcher-1.4.7-19.zip
	https://proxy.golang.org/gopkg.in/yaml.v3/@v/v3.0.1.info
		-> n8n-launcher-1.4.7-19.info
"

S="${WORKDIR}/n8n-source"

LICENSE="
	Sustainable-Use-1.0 n8n-Enterprise
	|| ( AFL-2.1 BSD )
	0BSD Apache-2.0 BlueOak-1.0.0 BSD BSD-2 ISC MIT PSF-2 Unlicense
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc ${PYTHON_REQUIRED_USE}"
RESTRICT="bindist mirror"

BDEPEND+="
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
	local entry relative filename
	unpack "${P}-n8n-source.tar.gz" "${P}-launcher-${LAUNCHER_VERSION}.tar.gz"
	mv "n8n-n8n-${PV}" "${S}" || die
	mv "task-runner-launcher-${LAUNCHER_VERSION}" "${WORKDIR}/launcher" || die
	mkdir "${WORKDIR}/pnpm" || die
	pushd "${WORKDIR}/pnpm" >/dev/null || die
	unpack "pnpm-${PNPM_VERSION}.tgz"
	chmod +x package/bin/pnpm.cjs || die
	popd >/dev/null || die
	export GOPROXY="file://${T}/go-proxy" GOSUMDB=off GOTOOLCHAIN=local
	for entry in "${LAUNCHER_GO_PROXY_FILES[@]}"; do
		relative=${entry%%|*}
		filename=${entry#*|}
		mkdir -p "${T}/go-proxy/${relative%/*}" || die
		ln -s "${DISTDIR}/${filename}" "${T}/go-proxy/${relative}" || die
	done
	pushd "${WORKDIR}/launcher" >/dev/null || die
	ego mod download
	ego mod verify
	popd >/dev/null || die
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
	grep -Fq -- "${new}" "${file}" && return 0
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
	{
		for (( i = 0; i < ${#N8N_TASK_RUNNERS_PNPM_SRC_URI[@]}; i++ )); do
			entry=${N8N_TASK_RUNNERS_PNPM_SRC_URI[i]}
			printf '%s\t%s\t%s\n' "${entry##* -> }" \
				"${N8N_TASK_RUNNERS_PNPM_PACKAGE_IDS[i]}" "${entry%% -> *}"
		done
	} | "${PYTHON}" "${FILESDIR}/n8n-pnpm-11-store-aliases.py" "${store}" || die

	export CI=true pnpm_config_offline=true npm_config_offline=true pnpm_config_store_dir="${store}"
	export npm_config_cache="${T}/npm-cache" PNPM_HOME="${T}/pnpm-home" COREPACK_HOME="${T}/corepack"
	"${PYTHON}" "${FILESDIR}/n8n-task-runners-create-pnpm-metadata-11.py" \
		pnpm-lock.yaml "${T%/temp}/homedir/.cache/pnpm" || die
	runner_pnpm install --filter '@n8n/task-runner...' --frozen-lockfile --offline --ignore-scripts --store-dir "${store}"
	sha256sum --check "${T}/pnpm-lock.sha256" || die "pnpm modified pnpm-lock.yaml"
}

src_compile() {
	local deploy="${WORKDIR}/javascript" isolated_deploy jobs manifest native_addon node_gyp npm_root
	local venv="${WORKDIR}/python/.venv" purelib runtime_addon
	export CI=true NODE_ENV=production DOCKER_BUILD=true pnpm_config_offline=true npm_config_offline=true
	export NODE_OPTIONS="--max-old-space-size=7168"
	export pnpm_config_store_dir="${T}/pnpm-store" npm_config_cache="${T}/npm-cache"
	export PNPM_HOME="${T}/pnpm-home" COREPACK_HOME="${T}/corepack"
	export PATH="${WORKDIR}/pnpm/package/bin:${PATH}"
	ln -sf pnpm.cjs "${WORKDIR}/pnpm/package/bin/pnpm" || die
	runner_pnpm --filter '@n8n/task-runner...' run build
	replace_literal packages/frontend/editor-ui/package.json \
		"github:rhashimoto/wa-sqlite#779219540f66cecaa159da32b3b8936697ba10a7" \
		"file:${DISTDIR}/${N8N_TASK_RUNNERS_WA_SQLITE_DISTFILE}"
	while IFS= read -r -d '' manifest; do
		if grep -Fq \
			-e "github:rhashimoto/wa-sqlite#779219540f66cecaa159da32b3b8936697ba10a7" \
			"${manifest}"; then
			die "unreplaced direct dependency in ${manifest}"
		fi
	done < <(find packages -name package.json -print0)
	"${PYTHON}" "${FILESDIR}/n8n-task-runners-create-pnpm-metadata-11.py" \
		pnpm-lock.yaml "${T%/temp}/homedir/.cache/pnpm" || die
	runner_pnpm --filter=@n8n/task-runner --prod --legacy deploy --no-optional --offline --ignore-scripts "${deploy}"
	mkdir -p "${deploy}/node_modules/moment" || die
	tar -xzf "${DISTDIR}/${N8N_TASK_RUNNERS_MOMENT_DISTFILE}" \
		--strip-components=1 -C "${deploy}/node_modules/moment" || die
	isolated_deploy=$(find "${deploy}/node_modules/.pnpm" -type d \
		-path '*/isolated-vm@7.0.1/node_modules/isolated-vm' -print -quit) || die
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
	find "${deploy}" -type f \( -path '*/@sentry-internal/node-cpu-profiler/lib/*.node' -o \
		-path '*/@sentry/node-cpu-profiler/lib/*.node' \) -delete || die
	find "${deploy}" -type f \( -path '*/@sentry-internal/node-native-stacktrace/lib/*.node' -o \
		-path '*/@sentry/node-native-stacktrace/lib/*.node' \) -delete || die
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
