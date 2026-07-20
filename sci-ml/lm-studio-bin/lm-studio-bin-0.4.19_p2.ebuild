# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit desktop

DESCRIPTION="Desktop application for running local large language models"
HOMEPAGE="https://lmstudio.ai/"

MY_PV="0.4.19-2"
SRC_URI="
	amd64? ( https://installers.lmstudio.ai/linux/x64/${MY_PV}/LM-Studio-${MY_PV}-x64.AppImage -> ${P}-amd64.AppImage )
	arm64? ( https://installers.lmstudio.ai/linux/arm64/${MY_PV}/LM-Studio-${MY_PV}-arm64.AppImage -> ${P}-arm64.AppImage )
"

S=${WORKDIR}

LICENSE="all-rights-reserved"
SLOT="0"
# Upstream provides arm64, but native arm64 runtime testing is still needed.
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cpu_flags_x86_avx2"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx2 )"

# The terms prohibit redistribution and modification of the application.
RESTRICT="bindist mirror splitdebug strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-fs/fuse:0
	virtual/udev
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
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
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"
# xdg{,-utils}.eclass do not support EAPI 9 yet; update this cache explicitly.
IDEPEND="dev-util/desktop-file-utils"

QA_PREBUILT="opt/${PN}/LM-Studio.AppImage"

src_install() {
	local appimage=${P}-${ARCH}.AppImage

	insinto /opt/${PN}
	newins "${DISTDIR}/${appimage}" LM-Studio.AppImage
	fperms 0755 /opt/${PN}/LM-Studio.AppImage

	newbin "${FILESDIR}/${PN}" lm-studio
	make_desktop_entry lm-studio \
		--args %U \
		--desktopid lm-studio \
		--name "LM Studio" \
		--icon applications-development \
		--categories Development \
		--entry "StartupWMClass=LM-Studio" \
		--entry "MimeType=x-scheme-handler/lmstudio;"
}

pkg_postinst() {
	ebegin "Updating desktop file database"
	update-desktop-database -q "${EROOT}"/usr/share/applications
	eend $?

	ewarn "LM Studio is proprietary software governed by its upstream terms:"
	ewarn "https://lmstudio.ai/app-terms"
	ewarn "Do not pass --no-sandbox unless normal execution fails and you consciously"
	ewarn "accept the reduced Chromium process isolation."
}

pkg_postrm() {
	ebegin "Updating desktop file database"
	update-desktop-database -q "${EROOT}"/usr/share/applications
	eend $?
}
