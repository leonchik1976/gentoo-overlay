# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature pax-utils unpacker xdg

DESCRIPTION="Viber for Desktop - calls and messaging companion app"
HOMEPAGE="https://www.viber.com/"
# The vendor's CDN URL always serves the latest release regardless of
# filename, so it cannot be pinned to this ebuild's exact version for
# automatic, integrity-checked fetching.
SRC_URI="
	amd64? (
		https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
			-> ${P}-amd64.deb
	)
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. Viber's official Linux .deb, and
# every bundled binary/plugin inside it, is x86_64-only (readelf-verified);
# Viber Media publishes no arm64 Linux build.
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="fetch mirror strip"

# Viber ships (and rpath-loads via $ORIGIN:$ORIGIN/lib) its own private
# copy of Qt6, ffmpeg, ICU 60 and friends under /opt/viber/lib -- those are
# NOT system RDEPEND. RDEPEND below covers only the libraries that
# `readelf -d` on the real opt/viber/Viber binary and its plugins
# (opt/viber/plugins/platforms/libqxcb.so, plugins/tls/libqopensslbackend.so,
# lib/libQt6WebEngineCore.so.6, lib/libQt6Multimedia.so.6) show as NEEDED
# from outside that bundle, verified 2026-08-18. This is notably different
# from AUR's vpip-style "qt6-multimedia" style dependency list, since the
# Arch package does not carry a bundled Qt6 the way this official .deb does.
RDEPEND="
	dev-libs/nss
	dev-libs/openssl:0=
	elibc_glibc? ( sys-libs/glibc )
	media-libs/alsa-lib
	media-libs/libglvnd[X]
	media-libs/libpulse
	media-libs/mesa[gbm(+)]
	sys-apps/dbus
	virtual/udev
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXScrnSaver
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

QA_PREBUILT="opt/viber/*"

pkg_nofetch() {
	ewarn "Viber's CDN URL always serves the latest release regardless of"
	ewarn "filename, so it cannot be fetched automatically against a pinned"
	ewarn "version."
	ewarn
	ewarn "To fetch the distfile(s):"
	ewarn " 1. Visit https://www.viber.com/download/ and download the"
	ewarn "    Linux .deb."
	ewarn " 2. Save it as ${P}-amd64.deb in your DISTDIR directory."
	ewarn " 3. Re-run emerge."
	ewarn
	ewarn "If the site now serves a version newer than ${PV}, this ebuild's"
	ewarn "Manifest will reject it -- check for a newer ebuild version first."
}

src_install() {
	dodir /opt/viber
	cp -ar opt/viber/. "${D}/opt/viber/" || die

	pax-mark m "${ED}/opt/viber/Viber"
	dosym ../viber/Viber /opt/bin/viber

	domenu usr/share/applications/viber.desktop

	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg viber.svg
	local size
	for size in 16 24 32 48 64 96 128 256; do
		newicon -s "${size}" "usr/share/viber/${size}x${size}.png" viber.png
	done
	doicon usr/share/pixmaps/viber.png
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "native GTK3 file dialogs and theming" x11-libs/gtk+:3
	optfeature "Wayland platform integration" dev-libs/wayland
}
