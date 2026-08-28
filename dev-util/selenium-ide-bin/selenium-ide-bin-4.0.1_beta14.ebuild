# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# xdg.eclass only supports EAPI 7/8 (@SUPPORTED_EAPIS), so EAPI 9 is not
# usable here despite being otherwise preferred for new ebuilds.
EAPI=8

inherit desktop xdg

MY_PV="${PV/_beta/-beta.}"

DESCRIPTION="Record-and-playback IDE for Selenium test scripts (Electron app)"
HOMEPAGE="https://www.selenium.dev/selenium-ide/ https://github.com/SeleniumHQ/selenium-ide"

# NOTICE: this is an Electron app and upstream only provides an AppImage,
# built for x86-64 only (no arm64 asset exists for this or any release).
APPIMAGE="Selenium-IDE-${MY_PV}.AppImage"
SRC_URI="https://github.com/SeleniumHQ/selenium-ide/releases/download/v${MY_PV}/${APPIMAGE}"
S="${WORKDIR}"

# Own code + bundled npm dependencies (fully enumerated from every
# package.json under the extracted app.asar's node_modules -- MIT,
# Apache-2.0, BSD-3-Clause, ISC; no copyleft) plus Electron's own MIT
# license, plus the bundled Chromium build's own license set. Chromium's
# is taken from www-client/chromium's own LICENSE (same upstream codebase,
# already audited by Gentoo) rather than re-deriving it from scratch, minus
# its rar-USE-conditional unRAR entry (not applicable, no rar USE here);
# LICENSES.chromium.html is installed as documentation so this claim can be
# checked against the actual shipped text, per Chromium's own license
# script output, not just inferred from another package's ebuild.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0"
LICENSE+=" CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1"
LICENSE+=" MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft"
LICENSE+=" Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"
SLOT="0"
KEYWORDS="-* ~amd64"

# bindist: the bundled libffmpeg.so contains H.264 and AAC decoders
# (verified via `strings libffmpeg.so`, e.g. ff_h264_*, ff_aac_decoder) --
# the same patent-encumbered-codec situation www-client/google-chrome and
# other Chromium-derived binary packages restrict bindist for.
RESTRICT="bindist splitdebug"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	|| (
		media-libs/libcanberra-gtk3
		media-libs/libcanberra[gtk3(-)]
	)
	media-libs/libglvnd
	media-libs/mesa
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	virtual/zlib:=
	sys-process/lsof
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/pango
	x11-misc/xdg-utils
"

# Path-specific exceptions for the prebuilt ELF binaries this Electron/
# Chromium bundle actually ships (enumerated with `find`+`file` against the
# extracted AppImage), not a blanket "*". The selenium-manager helper ends
# up vendored at varying node_modules nesting depth, wherever this
# release's own dependency tree happened to pull selenium-webdriver in
# (directly or transitively) -- how many copies exist, and at what depth,
# is release-specific, so that part of the list is discovered from the
# installed image itself in src_install rather than hardcoded to a count
# that could go stale.
QA_PREBUILT="
	opt/selenium-ide/selenium-ide
	opt/selenium-ide/chrome-sandbox
	opt/selenium-ide/chrome_crashpad_handler
	opt/selenium-ide/libEGL.so
	opt/selenium-ide/libGLESv2.so
	opt/selenium-ide/libffmpeg.so
	opt/selenium-ide/libvk_swiftshader.so
	opt/selenium-ide/libvulkan.so.1
	opt/selenium-ide/resources/app.asar.unpacked/node_modules/electron-chromedriver/bin/chromedriver
	opt/selenium-ide/resources/app.asar.unpacked/node_modules/electron-chromedriver/bin/chromedriver.debug
"

src_unpack() {
	mkdir -p "${S}" || die
	cp "${DISTDIR}/${APPIMAGE}" "${S}" || die

	cd "${S}" || die	# "appimage-extract" unpacks to current directory.
	chmod +x "${S}/${APPIMAGE}" || die
	"${S}/${APPIMAGE}" --appimage-extract || die
}

src_prepare() {
	find "${S}" -type d -exec chmod a+rx {} + || die
	find "${S}" -type f -exec chmod a+r {} + || die

	default
}

src_install() {
	cd "${S}/squashfs-root" || die

	insinto /usr/share
	doins -r ./usr/share/icons

	# Keep the upstream-shipped attribution/license texts for the two big
	# bundled runtimes instead of discarding them.
	dodoc LICENSE.electron.txt LICENSES.chromium.html

	local apphome="/opt/${PN/-bin}"
	local -a toremove=(
		.DirIcon
		AppRun
		LICENSE.electron.txt
		LICENSES.chromium.html
		selenium-ide.png
		usr
	)
	rm -f -r "${toremove[@]}" || die

	mkdir -p "${ED}/${apphome}" || die
	cp -r . "${ED}/${apphome}" || die

	dosym -r "${apphome}/selenium-ide" "/usr/bin/${PN/-bin}"
	make_desktop_entry "${PN/-bin}" "Selenium IDE" selenium-ide "Development;" \
		"StartupWMClass=Selenium IDE"

	# Every nested copy of the vendored selenium-manager Linux binary --
	# however many there are, wherever this release's own node_modules
	# tree happened to place them -- gets the same prebuilt-ELF exception.
	local f
	while IFS= read -r -d '' f; do
		QA_PREBUILT+=" ${f#"${ED}"/}"
	done < <(find "${ED}${apphome}" -path '*/selenium-webdriver/bin/linux/selenium-manager' -print0)
}
