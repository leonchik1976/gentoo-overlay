# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Customizable falling-block puzzle game"
HOMEPAGE="https://github.com/mmatyas/openblok"
SRC_URI="https://github.com/mmatyas/openblok/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+ BSD-2 ParaType-PT-Sans"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+nls test"
RESTRICT="mirror !test? ( test )"

DEPEND="
	media-libs/libsdl2[joystick,video]
	media-libs/sdl2-image[jpeg,png]
	media-libs/sdl2-mixer[mp3,vorbis,wav]
	media-libs/sdl2-ttf
	>=media-libs/libsdl2pp-0.18.1:=
	nls? ( virtual/libintl )
"
RDEPEND="${DEPEND}"
DEPEND+=" test? ( dev-libs/unittest++ )"
BDEPEND="${BDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

PATCHES=( "${FILESDIR}/${P}-system-libraries.patch" )

src_prepare() {
	default
	# The Helsinki notice permits use but does not expressly permit redistribution.
	# Use the already bundled, redistributable PT Sans bold font for countdowns.
	sed -i 's/helsinki.ttf/PTS75F.ttf/' src/game/states/substates/ingame/Countdown.cpp || die
	# Make the upstream HTML entities readable without changing the terms.
	sed -i -e 's/\&amp;quot;/"/g' -e 's/\&amp;amp;/\&/g' \
		"data/fonts/Paratype PT Sans Free Font License.txt" || die
	rm data/fonts/helsinki.ttf "data/fonts/Vic Fieger License.txt" || die
	cmake_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_TESTS=$(usex test)
		-DBUILD_TEST_COVERAGE=OFF
		-DENABLE_LOCALES=$(usex nls)
		-DEXEDIR="${EPREFIX}/usr/bin"
		-DDATADIR="${EPREFIX}/usr/share/openblok"
		-DINSTALL_PORTABLE=OFF
		-DENABLE_JPG=ON
		-DENABLE_MP3=ON
		-DENABLE_FLAC=OFF
		-DENABLE_MOD=OFF
	)
	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}/tests/openblok_test" || die "Tests failed"
}

src_install() {
	cmake_src_install
	newdoc thirdparty/tinydir/tinydir.h tinydir-license-and-source.h
	# Upstream's data installation excludes *.txt, including required font notices.
	insinto /usr/share/openblok/fonts
	doins data/fonts/*.txt
}
