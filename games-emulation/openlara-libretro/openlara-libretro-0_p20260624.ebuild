# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit toolchain-funcs

MY_COMMIT="e4ce52edec5a9a6ad22b69d08c687bf070e68876"
DESCRIPTION="OpenLara Tomb Raider engine as a libretro core"
HOMEPAGE="https://github.com/libretro/OpenLara"
SRC_URI="https://github.com/libretro/OpenLara/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenLara-${MY_COMMIT}"

LICENSE="BSD-2 LGPL-2.1+ MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="media-libs/libglvnd"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	# Retain the Makefile's required defines/includes, but honour user optimisation.
	sed -i -e '/CXXFLAGS += -O[03]/d' -e '/CFLAGS += -O[03]/d' \
		src/platform/libretro/Makefile || die
}

src_compile() {
	tc-export CC CXX
	# Generic Unix works on both architectures; armv* targets set ARM32-only flags.
	export CFLAGS="${CPPFLAGS} ${CFLAGS}" CXXFLAGS="${CPPFLAGS} ${CXXFLAGS}"
	emake -C src/platform/libretro platform=unix
}

src_install() {
	exeinto /usr/$(get_libdir)/libretro
	doexe src/platform/libretro/openlara_libretro.so
	dodoc LICENSE src/libs/minimp3/minimp3.{cpp,h} \
		src/libs/tinf/{tinflate.c,tinf.h} src/libs/stb_vorbis/stb_vorbis.c \
		src/libs/gl/glext.h
	dodoc -r src/platform/libretro/libretro-common
	einstalldocs
}

pkg_postinst() {
	elog "Load openlara_libretro.so with a libretro frontend configured for OpenGL."
	elog "Original Tomb Raider game data is required. See upstream README.md."
}
