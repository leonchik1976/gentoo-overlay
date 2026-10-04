# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A dedicated music player for your Plex media library"
HOMEPAGE="https://www.plex.tv/plexamp/"
SRC_URI="
	amd64? ( https://plexamp.plex.tv/desktop/Plexamp-${PV}-x86_64.AppImage )
	arm64? ( https://plexamp.plex.tv/desktop/Plexamp-${PV}-aarch64.AppImage )
"

S="${WORKDIR}"
# Proprietary Plex application and third-party libraries bundled in the AppImage.
# Their copyright notices remain inside the installed image.
LICENSE="
	all-rights-reserved Apache-2.0 BSD BSD-2 BZIP2 CC0-1.0 GPL-2+ GPL-3+
	IJG LGPL-2+ LGPL-2.1 LGPL-2.1+ LGPL-3+ libpng libtiff MIT MPL-2.0
	public-domain Sleepycat ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
# Stripping or splitdebug processing would corrupt the embedded filesystem.
RESTRICT="bindist mirror splitdebug strip"

# GTK, WebKit and most of their dependencies are bundled. These libraries are
# required by DT_NEEDED entries outside the bundle, or loaded for audio/graphics.
RDEPEND="
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/glib:2
	dev-libs/gmp
	dev-libs/libgpg-error
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd[X]
	media-libs/mesa[opengl]
	sys-apps/dbus
	sys-fs/e2fsprogs
	sys-fs/fuse:0
	>=sys-libs/glibc-2.39
	virtual/jack
	virtual/zlib
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
"

QA_PREBUILT="usr/bin/plexamp"

src_unpack() {
	local arch=x86_64
	use arm64 && arch=aarch64
	cp "${DISTDIR}/Plexamp-${PV}-${arch}.AppImage" plexamp.AppImage || die
	chmod +x plexamp.AppImage || die
	./plexamp.AppImage --appimage-extract || die
}

src_prepare() {
	default
	sed -i -e "s|^Exec=.*$|Exec=${EPREFIX}/usr/bin/plexamp %u|" \
		squashfs-root/usr/share/applications/Plexamp.desktop || die
}

src_install() {
	newbin plexamp.AppImage plexamp
	domenu squashfs-root/usr/share/applications/Plexamp.desktop
	insinto /usr/share/icons/hicolor
	doins -r squashfs-root/usr/share/icons/hicolor/.
}
