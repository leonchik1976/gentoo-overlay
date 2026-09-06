# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# unpacker.eclass and xdg.eclass are @SUPPORTED_EAPIS: 7 8 in ::gentoo, so
# a .deb-unpacking ebuild cannot move to EAPI 9 yet.

inherit desktop optfeature unpacker xdg

MY_PN="${PN%-bin}"
# Per-release build id embedded in the Cursor CDN download path; changes
# with every version and must be refreshed on each bump (grab it from the
# links on https://x.ai/bot#download or https://cursor.com/download/bot).
MY_BUILD="dd6e1fd3efb029e94e3c9d5c4d3e66510a917395"

DESCRIPTION="Grok Bot desktop agent: xAI's always-on AI teammates"
HOMEPAGE="https://x.ai/bot https://docs.x.ai/grok-bot/get-started"
SRC_URI="
	amd64? (
		https://downloads.cursor.com/grokbot/stable/${MY_BUILD}/linux/x64/${MY_PN}_${PV}_amd64.deb
		-> ${P}_amd64.deb
	)
	arm64? (
		https://downloads.cursor.com/grokbot/stable/${MY_BUILD}/linux/arm64/${MY_PN}_${PV}_arm64.deb
		-> ${P}_arm64.deb
	)
"
S="${WORKDIR}"

# No licence or EULA is shipped for the Grok Bot application itself and
# the .deb's control "License" field is "unknown"; it is proprietary,
# governed by Anysphere's and xAI's online terms, grants no
# redistribution rights -> all-rights-reserved, and must not be mirrored
# by Gentoo. The package does ship LICENSE.electron.txt (Electron, MIT)
# and LICENSES.chromium.html (761 third-party notices). The rest of the
# list below is the bundled Chromium 148 / Electron 42 inventory: it
# tracks www-client/chromium's LICENSE (minus rar-only unRAR), cross-
# checked against LICENSES.chromium.html in this distfile, plus APSL-2
# (Apple CF/Darwin notices in that file), libpng, public-domain (SQLite)
# and an LGPL-2.1+ libffmpeg.so.
LICENSE="
	all-rights-reserved
	Apache-2.0 Apache-2.0-with-LLVM-exceptions APSL-2 Base64 Boost-1.0 BSD
	BSD-2 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1
	LGPL-2.1+ libpng libtiff MIT MPL-1.1 MPL-2.0 Ms-PL openssl PSF-2
	public-domain SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015
	Unlicense UoI-NCSA ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="suid"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/libudev
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
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libxkbcommon
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/${MY_PN}/*"

src_prepare() {
	default

	# Debian packaging bits that are not meaningful on Gentoo: the bundled
	# AppArmor profile is loaded by the .deb maintainer scripts, and the
	# changelog only records "Package created with FPM".
	rm "opt/Grok Bot/resources/apparmor-profile" || die
	rm -r usr/share/doc || die
}

src_install() {
	# Upstream installs to "/opt/Grok Bot" (with a space); relocate to a
	# conventional path. The .desktop file uses "Exec=grok-bot", resolved
	# through the symlink below, so it needs no patching.
	dodir /opt
	cp -a "opt/Grok Bot" "${ED}/opt/${MY_PN}" || die

	dosym -r "/opt/${MY_PN}/${MY_PN}" "/usr/bin/${MY_PN}"

	local size
	for size in 16 24 32 48 64 128 256 512; do
		doicon -s ${size} "usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png"
	done
	domenu "usr/share/applications/${MY_PN}.desktop"

	# chrome-sandbox: Chromium's namespace sandbox works from unprivileged
	# user namespaces alone on a typical Gentoo kernel; the setuid helper
	# is only a fallback for kernels or sysctls that disable those. See the
	# suid USE flag description.
	if use suid; then
		fperms 4755 "/opt/${MY_PN}/chrome-sandbox"
	else
		fperms 0755 "/opt/${MY_PN}/chrome-sandbox"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Grok Bot requires signing in with a Cursor account on an eligible"
	elog "paid plan: SuperGrok Plus, SuperGrok Heavy, Cursor Pro+, Cursor"
	elog "Ultra, or Cursor Teams Standard or Premium. It has no offline or"
	elog "standalone mode."
	elog
	elog "The in-app updater is not integrated with Portage; update Grok Bot"
	elog "by bumping this package."
	elog
	optfeature "the system tray icon" dev-libs/libayatana-appindicator
	optfeature "native file dialogs and screen sharing via xdg-desktop-portal" \
		sys-apps/xdg-desktop-portal-gtk sys-apps/xdg-desktop-portal-gnome \
		kde-plasma/xdg-desktop-portal-kde
}

pkg_postrm() {
	xdg_pkg_postrm
}
