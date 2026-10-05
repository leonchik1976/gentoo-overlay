# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_COMMIT="3b268ca4bf986c380f44a26ffd9218bf6d376249"
DESCRIPTION="Open-source reimplementation of the classic Tomb Raider engine"
HOMEPAGE="https://github.com/XProger/OpenLara"
SRC_URI="https://github.com/XProger/OpenLara/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenLara-${MY_COMMIT}"

LICENSE="BSD-2 LGPL-2.1+ MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	media-libs/libglvnd[X]
	media-libs/libpulse
	x11-libs/libX11
"
RDEPEND="${DEPEND}"

src_compile() {
	# The native Unix frontend has only a build.sh; use Portage's compiler and flags.
	$(tc-getCXX) ${CPPFLAGS} ${CXXFLAGS} \
		-std=c++11 -fno-exceptions -fno-rtti -DNDEBUG \
		-D_POSIX_THREADS -D_POSIX_READER_WRITER_LOCKS -Isrc \
		src/platform/nix/main.cpp \
		src/libs/stb_vorbis/stb_vorbis.c \
		src/libs/minimp3/minimp3.cpp src/libs/tinf/tinflate.c \
		${LDFLAGS} -o openlara -lX11 -lGL -lm -lpthread \
		-lpulse-simple -lpulse || die
}

src_install() {
	dobin openlara
	dodoc LICENSE src/libs/minimp3/minimp3.{cpp,h} \
		src/libs/tinf/{tinflate.c,tinf.h} src/libs/stb_vorbis/stb_vorbis.c \
		src/libs/gl/glext.h
	einstalldocs
}

pkg_postinst() {
	elog "Original Tomb Raider game data is required. Run openlara from the"
	elog "directory containing level/, audio/ and video/. Saves use ~/.openlara."
}
