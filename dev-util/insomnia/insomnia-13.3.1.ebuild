# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# python-any-r1 and xdg do not support EAPI 9.
EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit desktop multiprocessing python-any-r1 toolchain-funcs xdg
inherit insomnia-npm-deps-13.3.1

DESCRIPTION="HTTP, GraphQL, and gRPC client built from source, with bundled Electron"
HOMEPAGE="https://insomnia.rest https://github.com/Kong/insomnia"
ELECTRON_VERSION=43.2.0
GRPC_COMMIT=f806b5a0dc2092b7a6fb54dfb66c38fb58231774
SRC_URI="
	https://github.com/Kong/insomnia/archive/refs/tags/core@${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Kong/grpc-reflection-js/archive/${GRPC_COMMIT}.tar.gz
		-> grpc-reflection-js-${GRPC_COMMIT}.tar.gz
	https://artifacts.electronjs.org/headers/dist/v${ELECTRON_VERSION}/node-v${ELECTRON_VERSION}-headers.tar.gz
		-> ${PN}-electron-headers-${ELECTRON_VERSION}.tar.gz
	amd64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip )
	arm64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-arm64.zip )
"
insomnia_npm_src_uri
S="${WORKDIR}/insomnia-core-${PV}"

# Application, Electron notices and bundled JavaScript/fonts. apiconnect-wsdl
# ships proprietary IBM notices referencing external IPLA/toolkit terms;
# all-rights-reserved conservatively records the unresolved redistribution grant.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT MIT-0 BSD BSD-2
	0BSD ISC BlueOak-1.0.0 Boost-1.0 CC-BY-3.0 CC-BY-4.0 CC0-1.0
	MPL-1.1 MPL-2.0 Ms-PL PSF-2 Unlicense GPL-2 LGPL-2 LGPL-2.1 LGPL-3
	FFT2D FTL IJG SGI-B-2.0 SunSoft UoI-NCSA ZLIB libpng2 libtiff
	Unicode-3.0 Unicode-DFS-2015 OFL-1.1 GSAP-Standard all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+abi_x86_64"
REQUIRED_USE="elibc_glibc amd64? ( abi_x86_64 )"
RESTRICT="bindist mirror"

RDEPEND="
	!dev-util/insomnia-bin
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0=
	media-libs/alsa-lib
	media-libs/mesa[opengl,gbm(+)]
	net-misc/curl[ssl,curl_ssl_openssl]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
"
DEPEND="dev-libs/openssl:0 net-misc/curl[ssl,curl_ssl_openssl]"
BDEPEND+="
	${PYTHON_DEPS}
	app-arch/unzip
	|| (
		>=net-libs/nodejs-24.18.0:0/24[npm]
		>=net-libs/nodejs-26.12.1:0/26[npm]
	)
	virtual/pkgconfig
"

# Only Electron is prebuilt; the libcurl addon is compiled against system libs.
QA_PREBUILT="opt/insomnia/insomnia opt/insomnia/chrome-sandbox
	opt/insomnia/chrome_crashpad_handler opt/insomnia/*.so*"
PATCHES=(
	"${FILESDIR}/${P}-lockfile.patch"
	"${FILESDIR}/${P}-node-26.patch"
)

pkg_setup() {
	python-any-r1_pkg_setup
	tc-is-cross-compiler && die "Build natively on amd64 or arm64"
	case $(node --version) in
		v24.*|v26.*) ;;
		*) die "This ebuild requires Node 24 or Node 26 to build" ;;
	esac
}

src_unpack() {
	unpack "${P}.tar.gz" "${PN}-electron-headers-${ELECTRON_VERSION}.tar.gz"
}

insomnia_build_env() {
	export npm_config_cache="${T}/npm-cache" npm_config_offline=true
	export npm_config_audit=false npm_config_fund=false npm_config_progress=false
	export ELECTRON_SKIP_BINARY_DOWNLOAD=1 PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
	export NODE_OPTIONS="--max-old-space-size=6144"
	export PATH="${S}/node_modules/.bin:${PATH}"
	tc-export CC CXX AR PKG_CONFIG
}

src_prepare() {
	default
	insomnia_build_env
	"${PYTHON}" "${FILESDIR}/insomnia-build.py" prepare "${S}" "${DISTDIR}" || die
	# Upstream enables engine-strict. The locked apiconnect-wsdl-2.0.36 engine
	# range (>=18.7.0 <25.0.0) rejects locally validated Node 26. Keep its warning
	# and override the strict check only for this offline dependency install.
	npm ci --offline --ignore-scripts --engine-strict=false --no-audit --no-fund || die
	node node_modules/patch-package/index.js --error-on-fail || die
	"${PYTHON}" "${FILESDIR}/insomnia-build.py" configure "${S}" || die
}

src_compile() {
	insomnia_build_env
	# The Git dependency ships generated protocol bindings, but needs TypeScript compilation.
	(cd node_modules/grpc-reflection-js && "${S}/node_modules/.bin/tsc" \
		--target es2020 --module commonjs --esModuleInterop --allowJs \
		--skipLibCheck --declaration --outDir build --rootDir . src/*.ts src/*.js) || die
	local module="${S}/node_modules/@getinsomnia/node-libcurl"
	(cd "${module}" && node "${S}/node_modules/node-gyp/bin/node-gyp.js" rebuild \
		--nodedir="${WORKDIR}/node_headers" --python="${PYTHON}" \
		--jobs="$(makeopts_jobs)" --module_name=node_libcurl \
		--module_path="${module}/lib/binding" \
		--curl_libraries="$(${PKG_CONFIG} --libs libcurl openssl)" ) || die
	npm run app-build || die
	[[ -s packages/insomnia/build/entry.main.min.js ]] || die "Main bundle missing"
	"${PYTHON}" "${FILESDIR}/insomnia-build.py" stage "${S}" "${WORKDIR}/app" || die
}

src_install() {
	local electron_arch=x64
	use arm64 && electron_arch=arm64
	mkdir "${T}/electron" || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-${electron_arch}.zip" \
		-d "${T}/electron" || die
	rm "${T}/electron/resources/default_app.asar" || die
	mv "${T}/electron/electron" "${T}/electron/insomnia" || die
	insinto /opt/insomnia
	doins -r "${T}/electron/."
	fperms +x /opt/insomnia/{insomnia,chrome-sandbox,chrome_crashpad_handler}
	fperms u+s /opt/insomnia/chrome-sandbox
	insinto /opt/insomnia/resources/app
	doins -r "${WORKDIR}/app/."
	insinto /opt/insomnia/resources/bin
	doins packages/insomnia/bin/yarn-standalone.js
	fperms +x /opt/insomnia/resources/bin/yarn-standalone.js
	dosym -r /opt/insomnia/insomnia /usr/bin/insomnia
	newicon -s scalable packages/insomnia/src/ui/images/insomnia-logo.svg insomnia.svg
	make_desktop_entry --eapi9 insomnia --args %U --name Insomnia --icon insomnia \
		--categories "Development;" --entry "MimeType=x-scheme-handler/insomnia;"
	dodoc LICENSE README.md
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "The application and libcurl addon are built locally; Electron is bundled."
	elog "This build omits the optional AI and external-vault bundle plugins."
	elog "The WSDL dependency includes proprietary IBM license notices."
}
