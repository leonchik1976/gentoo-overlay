# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# unpacker and xdg currently support EAPI 8, not EAPI 9.
EAPI=8

MY_PN="signal-desktop-beta"
MY_PV="${PV/_beta/-beta.}"

inherit unpacker xdg

DESCRIPTION="Allows you to send and receive messages of Signal Messenger on your computer"
HOMEPAGE="https://signal.org/
	https://github.com/signalapp/Signal-Desktop"
SRC_URI="https://updates.signal.org/desktop/apt-arm64/pool/s/${MY_PN}/${MY_PN}_${MY_PV}_arm64.deb"
S="${WORKDIR}"

# Corresponding Source: https://github.com/signalapp/Signal-Desktop/blob/v${MY_PV}/LICENSE
LICENSE="AGPL-3"
# From www-client/chromium for the bundled Electron runtime
LICENSE+=" Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL"
LICENSE+=" IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0"
LICENSE+=" Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"
# From net-libs/nodejs
LICENSE+=" Apache-1.1 BlueOak-1.0.0"
SLOT="0"
KEYWORDS="~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="splitdebug"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	>=media-fonts/noto-emoji-20231130
	media-libs/alsa-lib
	media-libs/libpulse
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( >=sys-libs/glibc-2.34 )
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/pango
"

QA_PREBUILT="opt/Signal*"

src_prepare() {
	default
	# Upstream ships an x86-64 fs-xattr addon even in its arm64 deb.
	# Its sole caller is guarded by process.platform === 'darwin'
	# (ts/windows/main/attachments.preload.ts); it is unused on Linux.
	rm -r "opt/Signal Beta/resources/app.asar.unpacked/node_modules/fs-xattr" || die
	unpack usr/share/doc/signal-desktop-beta/changelog.gz
	sed -i 's|^Exec=.* %U$|Exec=signal-desktop-beta %U|' \
		usr/share/applications/signal-desktop-beta.desktop || die
}

src_install() {
	insinto /opt
	doins -r "opt/Signal Beta"
	insinto /usr/share
	doins -r usr/share/applications usr/share/icons
	fperms +x "/opt/Signal Beta/"{signal-desktop-beta,chrome-sandbox,chrome_crashpad_handler}
	fperms u+s "/opt/Signal Beta/chrome-sandbox"
	dosym "../../opt/Signal Beta/signal-desktop-beta" /usr/bin/signal-desktop-beta
	dodoc changelog
}
