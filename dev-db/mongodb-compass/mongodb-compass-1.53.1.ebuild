# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# python-any-r1 and xdg-utils currently support EAPI 8, not EAPI 9.
EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit desktop multiprocessing python-any-r1 toolchain-funcs xdg-utils
inherit mongodb-compass-npm-deps-1.53.1

DESCRIPTION="MongoDB GUI built from source, with bundled Electron"
HOMEPAGE="https://www.mongodb.com/compass https://github.com/mongodb-js/compass"
ELECTRON_VERSION=45.0.0
MONGOCRYPT_VERSION=1.20.1
MONGOC_VERSION=2.3.3
SRC_URI="
	https://github.com/mongodb-js/compass/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/mongodb/libmongocrypt/archive/refs/tags/${MONGOCRYPT_VERSION}.tar.gz
		-> libmongocrypt-${MONGOCRYPT_VERSION}.tar.gz
	https://github.com/mongodb/mongo-c-driver/archive/refs/tags/${MONGOC_VERSION}.tar.gz
		-> mongo-c-driver-${MONGOC_VERSION}.tar.gz
	https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-arm64.zip
	https://artifacts.electronjs.org/headers/dist/v${ELECTRON_VERSION}/node-v${ELECTRON_VERSION}-headers.tar.gz
		-> ${PN}-electron-headers-${ELECTRON_VERSION}.tar.gz
"
mongodb_compass_npm_src_uri
S="${WORKDIR}/compass-${PV}"

# SSPL-1 is the application license; other licenses cover bundled dependencies.
LICENSE="SSPL-1 Apache-2.0 MIT BSD BSD-2 ISC BlueOak-1.0.0 0BSD CC0-1.0
	Artistic-2 MPL-2.0 CC-BY-3.0 CC-BY-4.0 WTFPL PSF-2
	Boost-1.0 FFT2D FTL IJG LGPL-2 LGPL-2.1 OFL-1.1
	Unicode-3.0 Unicode-DFS-2016 ZLIB Apache-2.0-with-LLVM-exceptions Clear-BSD MPL-1.1 Ms-PL SGI-B-2.0
	SunSoft Unicode-DFS-2015 Unlicense UoI-NCSA libtiff unRAR public-domain"
SLOT="0"
KEYWORDS="~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror"

RDEPEND="
	!dev-db/mongodb-compass-bin
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	virtual/krb5
	virtual/secret-service
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"
DEPEND="dev-libs/openssl:0/3 virtual/krb5"
BDEPEND+="
	${PYTHON_DEPS}
	app-arch/unzip
	dev-build/cmake
	>=net-libs/nodejs-24.15.0[npm]
	virtual/pkgconfig
"
IDEPEND+=" dev-util/desktop-file-utils"

# Only the Electron runtime is prebuilt; native npm addons are compiled locally.
QA_PREBUILT="
	opt/mongodb-compass/mongodb-compass
	opt/mongodb-compass/chrome-sandbox
	opt/mongodb-compass/chrome_crashpad_handler
	opt/mongodb-compass/*.so*
"

pkg_setup() {
	python-any-r1_pkg_setup
	tc-is-cross-compiler && die "Build natively on arm64"
}

src_unpack() {
	unpack "${P}.tar.gz" "libmongocrypt-${MONGOCRYPT_VERSION}.tar.gz" \
		"mongo-c-driver-${MONGOC_VERSION}.tar.gz" "${PN}-electron-headers-${ELECTRON_VERSION}.tar.gz"
}

compass_build_env() {
	export npm_config_cache="${T}/npm-cache" npm_config_offline=true
	export npm_config_audit=false npm_config_fund=false npm_config_progress=false
	export ELECTRON_SKIP_BINARY_DOWNLOAD=1 HUSKY=0 NX_DAEMON=false
	export HADRON_DISTRIBUTION=compass HADRON_SKIP_INSTALLER=true
	export PATH="${S}/node_modules/.bin:${PATH}"
	export NODE_OPTIONS="--max-old-space-size=4096"
	tc-export CC CXX AR
}

src_prepare() {
	default
	compass_build_env
	"${PYTHON}" "${FILESDIR}/mongodb-compass-build.py" prepare "${S}" "${DISTDIR}" || die
	npm ci --offline --ignore-scripts --no-audit --no-fund || die
	mkdir -p node_modules/electron/dist || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-arm64.zip" \
		-d node_modules/electron/dist || die
	echo electron > node_modules/electron/path.txt || die
	# Use the stylesheet's normal sans-serif fallback instead of downloading
	# proprietary Euclid fonts. The enterprise crypt_shared download is also
	# skipped; upstream already handles its absence and accepts an external path.
	echo '/* Use the system sans-serif fallback. */' > packages/compass/src/app/styles/fonts.less || die
	# Updates to this arm64 source build are managed through Portage.
	sed -i 's/void CompassAutoUpdateManager.init(this);/return; \/\/ Managed by Portage./' \
		packages/compass/src/main/application.ts || die
}

src_configure() {
	compass_build_env
	cmake -S "${WORKDIR}/libmongocrypt-${MONGOCRYPT_VERSION}" -B "${WORKDIR}/crypt-build" \
		-DCMAKE_BUILD_TYPE=Gentoo -DCMAKE_INSTALL_PREFIX="${T}/crypt" \
		-DCMAKE_INSTALL_LIBDIR=lib -DBUILD_VERSION="${MONGOCRYPT_VERSION}" \
		-DMONGOCRYPT_MONGOC_DIR="${WORKDIR}/mongo-c-driver-${MONGOC_VERSION}" \
		-DDISABLE_NATIVE_CRYPTO=ON -DENABLE_ONLINE_TESTS=OFF -DBUILD_TESTING=OFF \
		-DENABLE_MORE_WARNINGS_AS_ERRORS=OFF || die
}

src_compile() {
	compass_build_env
	cmake --build "${WORKDIR}/crypt-build" --parallel "$(makeopts_jobs)" || die
	cmake --install "${WORKDIR}/crypt-build" || die
	mkdir -p node_modules/mongodb-client-encryption/deps || die
	cp -r "${T}/crypt/." node_modules/mongodb-client-encryption/deps || die
	local module
	for module in interruptor kerberos os-dns-native \
		@mongodb-js/native-machine-id mongodb-client-encryption; do
		(cd "node_modules/${module}" && node "${S}/node_modules/node-gyp/bin/node-gyp.js" \
			rebuild --nodedir="${WORKDIR}/node_headers" --python="${PYTHON}" --built_with_electron=1) || die
	done
	# Optional NAN accelerators do not support this Electron/V8 release.
	# Keep SSH2's baseline cipher ordering and JavaScript crypto implementations.
	"${PYTHON}" "${FILESDIR}/mongodb-compass-build.py" configure "${S}" || die
	npm exec --offline -- lerna run bootstrap --concurrency 2 || die
	npm run compile --workspace=packages/compass || die
	"${PYTHON}" "${FILESDIR}/mongodb-compass-build.py" stage "${S}" "${WORKDIR}/app" || die
}

src_install() {
	local appdir=/opt/${PN} electron_dir
	electron_dir=$(mktemp -d "${T}/electron.XXXXXX") || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-arm64.zip" \
		-d "${electron_dir}" || die
	rm "${electron_dir}/resources/default_app.asar" || die
	mv "${electron_dir}/electron" "${electron_dir}/${PN}" || die
	insinto "${appdir}"
	doins -r "${electron_dir}/."
	fperms +x "${appdir}/"{${PN},chrome-sandbox,chrome_crashpad_handler}
	fperms u+s "${appdir}/chrome-sandbox"
	insinto "${appdir}/resources/app"
	doins -r "${WORKDIR}/app/."
	dosym "../../opt/${PN}/${PN}" "/usr/bin/${PN}"
	newicon packages/compass/app-icons/linux/mongodb-compass-logo-stable.png ${PN}.png
	make_desktop_entry "${PN} %U" "MongoDB Compass" "${PN}" "Development;Database;" \
		"MimeType=x-scheme-handler/mongodb;x-scheme-handler/mongodb+srv;"
	dodoc LICENSE README.md packages/compass/THIRD-PARTY-NOTICES.md
	docinto libmongocrypt
	dodoc "${WORKDIR}/libmongocrypt-${MONGOCRYPT_VERSION}/LICENSE"
	newdoc "${WORKDIR}/libmongocrypt-${MONGOCRYPT_VERSION}/kms-message/COPYING" kms-message-COPYING
	newdoc "${WORKDIR}/libmongocrypt-${MONGOCRYPT_VERSION}/kms-message/THIRD_PARTY_NOTICES" kms-message-NOTICES
	newdoc "${WORKDIR}/crypt-build/_deps/intel_dfp-src/eula.txt" Intel-DFP-LICENSE
	docinto mongo-c-driver
	dodoc "${WORKDIR}/mongo-c-driver-${MONGOC_VERSION}/"{COPYING,THIRD_PARTY_NOTICES}
	newdoc "${WORKDIR}/mongo-c-driver-${MONGOC_VERSION}/src/libbson/THIRD_PARTY_NOTICES" libbson-NOTICES
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	elog "This source build uses system fonts and does not bundle enterprise crypt_shared."
	elog "If needed, provide a compatible library using COMPASS_CRYPT_LIBRARY_PATH."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
