# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# python-any-r1 and xdg-utils currently support EAPI 8, not EAPI 9.
EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
PYTHON_REQ_USE="sqlite"
CHECKREQS_MEMORY="8G"
CHECKREQS_DISK_BUILD="6G"

inherit check-reqs desktop multiprocessing python-any-r1 toolchain-funcs xdg-utils
inherit nimbalyst-npm-deps-0.82.1

DESCRIPTION="Visual workspace for coding agents, built from its TypeScript sources"
HOMEPAGE="https://nimbalyst.com/ https://github.com/nimbalyst/nimbalyst"

ELECTRON_VERSION="43.7.0"
PNPM_VERSION="12.9.1"
RIPGREP_VERSION="15.0.1"
SRC_URI="
	https://github.com/nimbalyst/nimbalyst/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://artifacts.electronjs.org/headers/dist/v${ELECTRON_VERSION}/node-v${ELECTRON_VERSION}-headers.tar.gz
		-> ${P}-electron-headers.tar.gz
	amd64? (
		https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip
		https://github.com/microsoft/ripgrep-prebuilt/releases/download/v${RIPGREP_VERSION}/ripgrep-v${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz
	)
	arm64? (
		https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-arm64.zip
		https://github.com/microsoft/ripgrep-prebuilt/releases/download/v${RIPGREP_VERSION}/ripgrep-v${RIPGREP_VERSION}-aarch64-unknown-linux-musl.tar.gz
	)
"
nimbalyst_npm_src_uri

# Own source: MIT. The assembled application also contains npm dependencies,
# Electron/Chromium, and Anthropic's proprietary native agent runtime.
# See upstream's generated THIRD_PARTY_LICENSES.json and the runtime notices.
LICENSE="MIT Apache-2.0 BSD BSD-2 ISC BlueOak-1.0.0 CC0-1.0 Unlicense 0BSD
	EPL-2.0 LGPL-3 PYTHON all-rights-reserved
	Boost-1.0 CC-BY-SA-4.0 FFT2D FTL IJG LGPL-2 LGPL-2.1 MPL-2.0
	OFL-1.1 PSF-2 Unicode-3.0 Unicode-DFS-2016 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
REQUIRED_USE="elibc_glibc"
# Bundled proprietary agent and patent-encumbered Electron media codecs.
RESTRICT="bindist mirror !test? ( test )"

# The bundled Codex Zsh requires GLIBC_2.38 on both architectures.
RDEPEND="
	app-arch/xz-utils
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi:0/8
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( >=sys-libs/glibc-2.38 )
	sys-libs/libcap
	sys-libs/ncurses:0/6
	virtual/libintl
	virtual/udev
	virtual/zlib
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
"
BDEPEND+="
	${PYTHON_DEPS}
	app-arch/unzip
	>=net-libs/nodejs-24
"
IDEPEND="dev-util/desktop-file-utils"

# These are upstream prebuilt dependencies, not the locally compiled PTY and
# SQLite addons. Do not exempt the latter from compiler flag/ELF checks.
QA_PREBUILT="
	opt/nimbalyst/nimbalyst
	opt/nimbalyst/chrome-sandbox
	opt/nimbalyst/chrome_crashpad_handler
	opt/nimbalyst/*.so*
	opt/nimbalyst/resources/claude-runtime/*/claude
	opt/nimbalyst/resources/app.asar.unpacked/node_modules/@openai/*/vendor/*/*
	opt/nimbalyst/resources/app.asar.unpacked/node_modules/@zed-industries/*/bin/*
	opt/nimbalyst/resources/app.asar.unpacked/node_modules/@vscode/ripgrep/bin/rg
	opt/nimbalyst/resources/app.asar.unpacked/node_modules/@img/*/lib/*
	opt/nimbalyst/resources/node_modules/onnxruntime-node/bin/*
"

PATCHES=(
	"${FILESDIR}/${P}-packaging.patch"
)

pkg_setup() {
	python-any-r1_pkg_setup
	check-reqs_pkg_setup
	[[ ${NIMBALYST_DEPS_VERSION} == ${PV} ]] || die "npm inputs do not match PV"
	tc-is-cross-compiler && die "Build natively: bundled build tools target the host architecture"
}

src_unpack() {
	# Registry archives must stay separate until imported into pnpm's store.
	unpack "${P}.tar.gz" "${P}-electron-headers.tar.gz"
}

nimbalyst_appdir() {
	if use amd64; then
		echo "${S}/packages/electron/release/linux-unpacked"
	else
		echo "${S}/packages/electron/release/linux-arm64-unpacked"
	fi
}

nimbalyst_build_env() {
	local arch=$(usex amd64 x64 arm64)
	export PATH="${T}/bin:${S}/node_modules/.bin:${PATH}"
	export XDG_CACHE_HOME="${T}/cache" XDG_CONFIG_HOME="${T}/config"
	export XDG_DATA_HOME="${T}/data" XDG_STATE_HOME="${T}/state" XDG_RUNTIME_DIR="${T}/run"
	export PNPM_HOME="${T}/pnpm-home" COREPACK_HOME="${T}/corepack"
	export ELECTRON_CACHE="${T}/electron-cache" ELECTRON_BUILDER_CACHE="${T}/builder-cache"
	export npm_config_cache="${T}/npm-cache" npm_config_devdir="${T}/node-gyp"
	export npm_config_nodedir="${WORKDIR}/node_headers" npm_config_python="${PYTHON}"
	export npm_config_runtime=electron npm_config_target="${ELECTRON_VERSION}"
	export npm_config_arch="${arch}" BUILD_ARCH="${arch}"
	export CI=true CSC_IDENTITY_AUTO_DISCOVERY=false
	export NODE_OPTIONS="--max-old-space-size=8192"
	export SHARP_IGNORE_GLOBAL_LIBVIPS=1
	tc-export CC CXX AR
}

src_prepare() {
	default
	nimbalyst_build_env
	local arch=$(usex amd64 x64 arm64)
	mkdir -p "${T}"/{bin,cache,config,data,state,run,pnpm-bootstrap} || die
	chmod 700 "${T}/run" || die
	tar -xf "${DISTDIR}/nimbalyst-npm-pnpm-exe.linux-${arch}-${PNPM_VERSION}.tgz" \
		-C "${T}/pnpm-bootstrap" --strip-components=1 || die
	ln -s "${T}/pnpm-bootstrap/pnpm" "${T}/bin/pnpm" || die
	{
		printf '%s\n' "${NIMBALYST_NPM_COMMON[@]}"
		if use amd64; then
			printf '%s\n' "${NIMBALYST_NPM_AMD64[@]}"
		else
			printf '%s\n' "${NIMBALYST_NPM_ARM64[@]}"
		fi
	} > "${T}/npm-inputs" || die
	"${PYTHON}" "${FILESDIR}/nimbalyst-build.py" seed \
		"${T}/npm-inputs" "${DISTDIR}" "${T}/pnpm-store" "${T}/state" "${T}/bin/pnpm" || die
	# Disable only time-dependent registry-age queries for the frozen inputs.
	# prepare also stages the pinned Electron and removes native addon prebuilds.
	# It must follow install, so apply the release-age adjustment first.
	sed -i 's/^minimumReleaseAge: 4320$/minimumReleaseAge: 0/' pnpm-workspace.yaml || die
	pnpm install --offline --frozen-lockfile --ignore-scripts \
		--store-dir "${T}/pnpm-store" --state-dir "${T}/state" || die
	# Restore the exact expected input for the checked preparation helper.
	sed -i 's/^minimumReleaseAge: 0$/minimumReleaseAge: 4320/' pnpm-workspace.yaml || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-${arch}.zip" \
		-d node_modules/electron/dist || die
	"${PYTHON}" "${FILESDIR}/nimbalyst-build.py" prepare "${S}" || die
	mkdir -p "${T}/ripgrep" node_modules/@vscode/ripgrep/bin || die
	local triple=$(usex amd64 x86_64 aarch64)-unknown-linux-musl
	tar -xf "${DISTDIR}/ripgrep-v${RIPGREP_VERSION}-${triple}.tar.gz" -C "${T}/ripgrep" || die
	local rg
	rg=$(find "${T}/ripgrep" -type f -name rg -print -quit) || die
	[[ -n ${rg} ]] || die "ripgrep archive lacks executable"
	cp "${rg}" node_modules/@vscode/ripgrep/bin/rg || die
	# Upstream forces LTO in this addon; honor the administrator's flags instead.
	sed -i -e "s/'-flto', //g" -e "s/, '-flto'//g" -e "s/\['-flto'\]/[]/g" \
		node_modules/better-sqlite3/binding.gyp || die
}

src_compile() {
	nimbalyst_build_env
	export NODE_ENV=production
	local module
	for module in node-pty better-sqlite3; do
		pushd "node_modules/${module}" >/dev/null || die
		node "${S}/node_modules/node-gyp/bin/node-gyp.js" rebuild \
			--nodedir="${WORKDIR}/node_headers" --arch="${BUILD_ARCH}" \
			--runtime=electron --target="${ELECTRON_VERSION}" --jobs="$(makeopts_jobs)" || die
		popd >/dev/null || die
	done
	pnpm run build:tracker-packages || die
	pnpm --dir packages/collab-protocol run build || die
	pnpm --dir packages/extension-sdk run build || die
	pnpm --dir packages/runtime run build || die
	pnpm --dir packages/electron run build:extensions || die
	pnpm --dir packages/electron run build || die
	pnpm --dir packages/electron run validate:extra-resources || die
	pnpm --dir packages/electron exec electron-builder --linux --"${BUILD_ARCH}" \
		--dir --publish never --config.electronDist="${S}/node_modules/electron/dist" || die
	"${PYTHON}" "${FILESDIR}/nimbalyst-build.py" tidy "${S}" "${BUILD_ARCH}" || die
}

src_test() {
	nimbalyst_build_env
	ELECTRON_RUN_AS_NODE=1 "$(nimbalyst_appdir)/nimbalyst" \
		"${FILESDIR}/nimbalyst-native-test.cjs" || die
}

src_install() {
	local app=$(nimbalyst_appdir)
	mkdir -p "${ED}/opt/nimbalyst" || die
	cp -a "${app}/." "${ED}/opt/nimbalyst/" || die
	fperms -R a+rX /opt/nimbalyst
	fowners -R root:root /opt/nimbalyst
	fperms 4711 /opt/nimbalyst/chrome-sandbox
	dosym ../../opt/nimbalyst/nimbalyst /usr/bin/nimbalyst
	fowners -h root:root /usr/bin/nimbalyst
	newicon -s 1024 packages/electron/icon.png nimbalyst.png
	domenu "${FILESDIR}/${PN}.desktop"
	dodoc LICENSE README.md LICENSING.md
	dodoc "${app}/LICENSE.electron.txt" "${app}/LICENSES.chromium.html"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	elog "Nimbalyst's application code was built from source. Electron and some"
	elog "third-party runtimes, including Anthropic's proprietary agent, are bundled."
	elog "Updates to this installation are managed by Portage."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
