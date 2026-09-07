# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar az bg bn bs ca cs da de el en-GB en-US es es-419 et fa fi fil fr
	gu he hi hr hu id it ja ka kk km kn ko lo lt lv mk ml mn mr ms my nb nl pl
	pt-BR pt-PT ro ru si sk sl sq sr sr-Latn sv sw ta te th tr uk ur uz vi
	zh-CN zh-TW
"

inherit chromium-2 desktop pax-utils unpacker xdg

DESCRIPTION="Brave web browser"
HOMEPAGE="https://brave.com/"

BRAVE_HOME="opt/brave.com/brave"
BRAVE_URI="https://github.com/brave/brave-browser/releases/download/v${PV}/brave-browser_${PV}_"
SRC_URI="
	amd64? ( ${BRAVE_URI}amd64.deb -> ${P}-amd64.deb )
	arm64? ( ${BRAVE_URI}arm64.deb -> ${P}-arm64.deb )
"

S="${WORKDIR}"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0"
LICENSE+=" CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT"
LICENSE+=" MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0"
LICENSE+=" Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="qt6"
REQUIRED_USE="elibc_glibc"

RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.35
	media-fonts/liberation-fonts
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa[gbm(+)]
	media-libs/vulkan-loader
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	|| (
		x11-libs/gtk+:3[X]
		gui-libs/gtk:4[X]
	)
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libxshmfence
	x11-libs/pango
	x11-misc/xdg-utils
	qt6? ( dev-qt/qtbase:6[gui,widgets] )
"

QA_PREBUILT="*"

pkg_pretend() {
	has "${ARCH}" amd64 arm64 ||
		die "${PN} supports only amd64 and arm64"
}

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack_deb "${A}"
}

src_prepare() {
	# Debian repository/update integration must not bypass Portage.
	rm -r etc "${BRAVE_HOME}/cron" || die

	# These are consumed only by Debian maintainer scripts.
	rm -r "${BRAVE_HOME}/apparmor.d" || die
	rm "${BRAVE_HOME}/default-app-block" || die
	rm -r usr/share/gnome-control-center || die

	mv usr/share/{appdata,metainfo} || die
	mv usr/share/doc/{brave-browser,${PF}} || die
	rmdir usr/share/doc/brave-browser-stable || die
	gunzip usr/share/doc/${PF}/changelog.gz || die
	gunzip usr/share/man/man1/brave-browser-stable.1.gz || die
	rm usr/share/man/man1/brave-browser.1.gz || die
	ln -s brave-browser-stable.1 usr/share/man/man1/brave-browser.1 || die

	pushd "${BRAVE_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	rm "${BRAVE_HOME}/libqt5_shim.so" || die
	if ! use qt6; then
		rm "${BRAVE_HOME}/libqt6_shim.so" || die
	fi

	eapply_user
}

src_install() {
	cp -a opt usr "${ED}" || die

	rm "${ED}/usr/bin/brave-browser-stable" || die
	dosym "../../${BRAVE_HOME}/brave-browser" /usr/bin/brave-browser-stable
	dosym brave-browser-stable /usr/bin/brave-browser
	dosym brave-browser-stable /usr/bin/${PN}

	local logo size
	for logo in "${ED}/${BRAVE_HOME}"/product_logo_*.png; do
		size=${logo##*_}
		size=${size%.*}
		newicon -s "${size}" "${logo}" brave-browser.png
	done

	# Both official Debian artifacts ship the Chromium sandbox mode 4755.
	fperms 4755 "/${BRAVE_HOME}/chrome-sandbox"
	pax-mark m "${ED}/${BRAVE_HOME}/brave"
}
