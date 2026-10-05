# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Brutal Doom gameplay modification for the Doom engine"
HOMEPAGE="https://www.moddb.com/mods/brutal-doom"
# Preserved official archive: MD5 a42f7a1f4fbec5b19591ece7f9811034 on ModDB.
SRC_URI="https://archive.org/download/brutalv21/brutalv21.rar"
S="${WORKDIR}"

# The archive has credits, including proprietary resources, but no general license.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"

RDEPEND="games-engines/uzdoom"
BDEPEND="app-arch/unrar"

src_unpack() {
	unpack_rar "${DISTDIR}/brutalv21.rar"
}

src_install() {
	insinto /usr/share/doom
	doins brutalv21.pk3
	dodoc "BRUTAL DOOM MANUAL.rtf" "bd21 changelog.txt"
}

pkg_postinst() {
	elog "Original Doom game data (IWAD) is required. Launch the mod with:"
	elog "  uzdoom -file ${EPREFIX}/usr/share/doom/brutalv21.pk3"
}
