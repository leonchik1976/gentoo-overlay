# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Mount cloud storage (S3, Box, Drive, SFTP, ...) as a local FUSE filesystem"
HOMEPAGE="https://www.expandrive.com/"
# The vendor's download endpoint always resolves to whatever the latest
# release currently is, regardless of URL, so it cannot be pinned to this
# ebuild's exact version for automatic, integrity-checked fetching.
SRC_URI="amd64? ( https://www.expandrive.com/api/download/expandrive?platform=linux&ext=deb -> ${P}-amd64.deb )"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. ExpanDrive's download API only
# serves an x86_64 .deb for platform=linux; no arm64 artifact exists in
# their build pipeline.
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="fetch mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	elibc_glibc? ( sys-libs/glibc )
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-fs/fuse:0
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/ExpanDrive/*"

pkg_nofetch() {
	ewarn "ExpanDrive's download endpoint always serves the latest release"
	ewarn "regardless of URL, so it cannot be fetched automatically against a"
	ewarn "pinned version."
	ewarn
	ewarn "To fetch the distfile(s):"
	ewarn " 1. Visit https://www.expandrive.com/download and download the"
	ewarn "    Linux .deb."
	ewarn " 2. Save it as ${P}-amd64.deb in your DISTDIR directory."
	ewarn " 3. Re-run emerge."
	ewarn
	ewarn "If the site now serves a version newer than ${PV}, this ebuild's"
	ewarn "Manifest will reject it -- check for a newer ebuild version first."
}

src_install() {
	insinto /opt/ExpanDrive
	doins -r opt/ExpanDrive/*

	fperms +x \
		/opt/ExpanDrive/expandrive \
		/opt/ExpanDrive/chrome_crashpad_handler \
		/opt/ExpanDrive/libEGL.so \
		/opt/ExpanDrive/libffmpeg.so \
		/opt/ExpanDrive/libGLESv2.so \
		/opt/ExpanDrive/libvk_swiftshader.so \
		/opt/ExpanDrive/libvulkan.so.1 \
		/opt/ExpanDrive/SharedSupport/exfs
	fowners root:root /opt/ExpanDrive/chrome-sandbox
	fperms 4711 /opt/ExpanDrive/chrome-sandbox

	dosym ../../opt/ExpanDrive/expandrive /usr/bin/expandrive

	local size
	for size in 16 32 48 64 128 256 512 1024; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/expandrive.png
	done
	domenu usr/share/applications/expandrive.desktop
}
