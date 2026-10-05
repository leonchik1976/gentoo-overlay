# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ bindings for SDL2, SDL2_image, SDL2_mixer and SDL2_ttf"
HOMEPAGE="https://github.com/libSDL2pp/libSDL2pp"
SRC_URI="https://github.com/libSDL2pp/libSDL2pp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/libSDL2pp-${PV}"

LICENSE="ZLIB"
SLOT="0/8"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	media-libs/sdl2-mixer
	media-libs/sdl2-ttf
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${P}-pkgconfig.patch" )

src_configure() {
	local mycmakeargs=(
		-DSDL2PP_WITH_IMAGE=ON
		-DSDL2PP_WITH_MIXER=ON
		-DSDL2PP_WITH_TTF=ON
		-DSDL2PP_WITH_EXAMPLES=OFF
		-DSDL2PP_WITH_TESTS=$(usex test)
		-DSDL2PP_ENABLE_LIVE_TESTS=OFF
		-DSDL2PP_STATIC=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
	)
	cmake_src_configure
}
