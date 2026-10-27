# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop unpacker xdg

DESCRIPTION="Open-source API client for exploring and testing APIs"
HOMEPAGE="https://www.usebruno.com https://github.com/usebruno/bruno"
SRC_URI="https://github.com/usebruno/bruno/releases/download/v${PV}/bruno_${PV}_arm64_linux.deb"
S="${WORKDIR}"

# Includes the bundled Electron/Chromium libraries; retain their notices.
LICENSE="Apache-2.0 BSD BSD-2 ISC LGPL-2.1+ MIT MPL-2.0 ZLIB"
SLOT="0"
KEYWORDS="~arm64"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	sys-devel/gcc
	sys-libs/glibc
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb:=
	x11-libs/libxkbcommon
	x11-libs/libnotify
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/Bruno/*"

src_configure() {
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	local size
	for size in 16 32 48 128 256 512 1024; do
		doicon -s "${size}" "usr/share/icons/hicolor/${size}x${size}/apps/bruno.png"
	done
	domenu usr/share/applications/bruno.desktop
	insinto /opt/Bruno
	doins -r opt/Bruno/.
	fperms 0755 /opt/Bruno/{bruno,chrome-sandbox,chrome_crashpad_handler}
	fowners root:root /opt/Bruno/chrome-sandbox
	fperms 4711 /opt/Bruno/chrome-sandbox
	dosym -r /opt/Bruno/bruno /usr/bin/bruno
}
