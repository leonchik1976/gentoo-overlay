# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# xdg-utils currently supports EAPI 8, not EAPI 9.
EAPI=8

# Resource packs from Electron 42.5.0, not JupyterLab interface translations.
CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW
"
inherit chromium-2 desktop xdg-utils jupyterlab-desktop-yarn-deps-4.6.3_p1

DESCRIPTION="JupyterLab desktop application, built from source with bundled Electron"
HOMEPAGE="https://github.com/jupyterlab/jupyterlab-desktop"
MY_PV=${PV/_p/-}
ELECTRON_VERSION=42.5.0
YARN_VERSION=1.22.22
SRC_URI="
	https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz
	https://github.com/jupyterlab/jupyterlab-desktop/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-arm64.zip
"
jupyterlab_desktop_yarn_src_uri
S="${WORKDIR}/${PN}-${MY_PV}"

# Application: BSD-3-Clause; npm packages and Electron have additional licenses.
LICENSE="BSD MIT ISC Apache-2.0 BSD-2 BlueOak-1.0.0 0BSD CC0-1.0
	Artistic-2 MPL-2.0 CC-BY-3.0 CC-BY-4.0 WTFPL PSF-2
	Boost-1.0 FFT2D FTL IJG LGPL-2 LGPL-2.1 OFL-1.1
	Unicode-3.0 Unicode-DFS-2016 ZLIB Apache-2.0-with-LLVM-exceptions Clear-BSD MPL-1.1 Ms-PL SGI-B-2.0
	SunSoft Unicode-DFS-2015 Unlicense UoI-NCSA libtiff unRAR public-domain"
SLOT="0"
KEYWORDS="~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror"

RDEPEND="
	!sci-misc/jupyterlab-desktop-bin
	>=dev-python/jupyterlab-3.0.0
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
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
BDEPEND+="
	app-arch/unzip
	>=net-libs/nodejs-24.15.0
"
IDEPEND+=" dev-util/desktop-file-utils"

QA_PREBUILT="
	opt/jupyterlab-desktop/jupyterlab-desktop
	opt/jupyterlab-desktop/chrome-sandbox
	opt/jupyterlab-desktop/chrome_crashpad_handler
	opt/jupyterlab-desktop/*.so*
"

PATCHES=( "${FILESDIR}/${P}-selected-python.patch" )

src_unpack() {
	unpack "${P}.tar.gz" "yarn-v${YARN_VERSION}.tar.gz"
}

src_prepare() {
	default
	# Gentoo supplies the Python environment; no bundled conda installer.
	# The existing environment chooser lets users select /usr/bin/pythonX.Y.
	mkdir -p "${T}/yarn-mirror" || die
	local archive
	for archive in ${A}; do
		[[ ${archive} == *.tgz ]] || continue
		ln -s "${DISTDIR}/${archive}" "${T}/yarn-mirror/${archive}" || die
	done
	cat > .yarnrc <<-EOF_YARN
		yarn-offline-mirror "${T}/yarn-mirror"
		cache-folder "${T}/yarn-cache"
		prefix "${T}/yarn-prefix"
		global-folder "${T}/yarn-global"
		disable-self-update-check true
	EOF_YARN
	# Electron is fetched by Portage, never by npm lifecycle scripts.
	node "${WORKDIR}/yarn-v${YARN_VERSION}/bin/yarn.js" install \
		--offline --frozen-lockfile --ignore-scripts --non-interactive || die
	mkdir -p node_modules/electron/dist || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-arm64.zip" \
		-d node_modules/electron/dist || die
	printf '%s' electron > node_modules/electron/path.txt || die
}

src_compile() {
	PATH="${WORKDIR}/yarn-v${YARN_VERSION}/bin:${PATH}" \
		node "${WORKDIR}/yarn-v${YARN_VERSION}/bin/yarn.js" --offline build || die
	# Keep only production dependencies in the installed application.
	node "${WORKDIR}/yarn-v${YARN_VERSION}/bin/yarn.js" install --offline --frozen-lockfile --ignore-scripts \
		--production --non-interactive || die
}

src_install() {
	local appdir=/opt/${PN} electron_dir
	electron_dir=$(mktemp -d "${T}/electron.XXXXXX") || die
	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-arm64.zip" \
		-d "${electron_dir}" || die
	(
		cd "${electron_dir}/locales" || die
		chromium_remove_language_paks
	) || die "Failed to prune Electron locale packs"
	# The default Electron demo must not override our application.
	rm "${electron_dir}/resources/default_app.asar" || die
	mv "${electron_dir}/electron" "${electron_dir}/${PN}" || die
	insinto "${appdir}"
	doins -r "${electron_dir}/."
	fperms +x "${appdir}/"{${PN},chrome-sandbox,chrome_crashpad_handler}
	fperms u+s "${appdir}/chrome-sandbox"
	insinto "${appdir}/resources/app"
	doins -r build node_modules package.json
	dosym "../../opt/${PN}/${PN}" "/usr/bin/${PN}"
	newicon -s 512 dist-resources/icons/512x512.png ${PN}.png
	make_desktop_entry "${PN} %F" "JupyterLab Desktop" "${PN}" "Science;Development;" \
		"MimeType=application/x-ipynb+json;"
	dodoc LICENSE README.md
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	elog "Select a Python environment containing JupyterLab on first launch."
	elog "This package uses Gentoo's Python packages and has no bundled conda environment."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
