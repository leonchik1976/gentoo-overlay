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

src_prepare() {
	default

	# 7zip-bin (a transitive dep of electron-builder-squirrel-windows, a
	# Windows-only build-time tool that ended up in the packaged
	# node_modules) bundles linux/{arm,arm64,ia32} and mac/* 7za helpers.
	# This package is amd64-only: the main ExpanDrive binary is
	# x86-64, and 7zip-bin/index.js resolves path7za to
	# linux/${process.arch}/7za, i.e. linux/x64/7za on this arch --
	# confirmed against the real .deb, not assumed from "arm64" appearing
	# in a bundled path. Verified nothing in ExpanDrive's own dist/*.js
	# ever calls path7za itself (every real reference traces back to
	# electron-builder-squirrel-windows/builder-util's own Windows
	# packaging code, never required by ExpanDrive's runtime), so this
	# strips what's definitely unreachable while leaving the one file
	# that would be selected if anything ever did call it.
	local sevenzip_dir="opt/ExpanDrive/resources/app.asar.unpacked/node_modules/7zip-bin"

	rm -r \
		"${sevenzip_dir}/linux/arm" \
		"${sevenzip_dir}/linux/arm64" \
		"${sevenzip_dir}/linux/ia32" \
		"${sevenzip_dir}/mac" \
		|| die

	# Docker/p7zip-source-compile scripts used only by 7zip-bin's own
	# upstream maintainers to rebuild the bundled 7za binary; not
	# referenced anywhere at runtime (confirmed: no reference to either
	# filename anywhere else in the packaged app).
	rm "${sevenzip_dir}/linux/x64/build.sh" "${sevenzip_dir}/linux/x64/do-build.sh" || die
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
		/opt/ExpanDrive/SharedSupport/exfs \
		/opt/ExpanDrive/resources/app.asar.unpacked/node_modules/7zip-bin/linux/x64/7za
	fowners root:root /opt/ExpanDrive/chrome-sandbox
	fperms 4711 /opt/ExpanDrive/chrome-sandbox

	dosym ../../opt/ExpanDrive/expandrive /usr/bin/expandrive

	local size
	for size in 16 32 48 64 128 256 512 1024; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/expandrive.png
	done
	domenu usr/share/applications/expandrive.desktop
}
