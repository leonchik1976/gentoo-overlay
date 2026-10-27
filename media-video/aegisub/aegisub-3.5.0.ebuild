# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( luajit )
LUA_REQ_USE="lua52compat"

WX_GTK_VER=3.2-gtk3
PLOCALES="ar be bg ca cs da de el es eu fa fi fr_FR gl hu id it ja ko lt nl pl pt_BR pt_PT ru sr_RS sr_RS@latin th tr uk_UA vi zh_CN zh_TW"

inherit meson flag-o-matic lua-single plocale wxwidgets xdg toolchain-funcs

DESCRIPTION="Advanced subtitle editor"
HOMEPAGE="https://aegisub.org/ https://github.com/TypesettingTools/Aegisub"
SRC_URI="https://github.com/TypesettingTools/Aegisub/releases/download/v${PV}/${P}.tar.xz"
S="${WORKDIR}/Aegisub-${PV}"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="+alsa debug +fftw openal portaudio pulseaudio spell test +uchardet"
REQUIRED_USE="
	${LUA_REQUIRED_USE}
	|| ( alsa openal portaudio pulseaudio )"
RESTRICT="!test? ( test )"

# aegisub bundles luabins (https://github.com/agladysh/luabins).
# Unfortunately, luabins upstream is practically dead since 2010.
# Thus unbundling luabins isn't worth the effort.
RDEPEND="${LUA_DEPS}
	>=x11-libs/wxGTK-3.2.2:${WX_GTK_VER}=[X,opengl,debug?]
	>=dev-libs/boost-1.70.0:=[icu,nls]
	>=dev-libs/icu-4.8.1.1:=
	>=media-libs/ffmpegsource-2.22:=
	media-libs/fontconfig
	media-libs/freetype
	>=media-libs/libass-0.9.7:=[fontconfig]
	virtual/zlib:=
	virtual/libiconv
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	fftw? ( >=sci-libs/fftw-3.3:= )
	openal? ( media-libs/openal )
	portaudio? ( =media-libs/portaudio-19* )
	pulseaudio? ( media-libs/libpulse )
	spell? ( app-text/hunspell:= )
	uchardet? ( app-i18n/uchardet )
"
DEPEND+="
	${RDEPEND}
	test? ( >=dev-cpp/gtest-1.14.0 )
"
BDEPEND+="
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}/${P}-matroska-recovery.patch" )

aegisub_check_compiler() {
	[[ ${MERGE_TYPE} == binary ]] && return
	test-flag-CXX -std=c++20 || die "Your compiler lacks C++20 support."
	# Check the library selected by either GCC or Clang; libc++ is unaffected.
	if [[ $(tc-get-cxx-stdlib) == libstdc++ ]]; then
		local libstdcxx
		libstdcxx=$($(tc-getCXX) ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} \
			-print-file-name=libstdc++.so) || die "Cannot locate libstdc++"
		libstdcxx=$(readlink -f "${libstdcxx}") || die "Cannot resolve libstdc++"
		[[ ${libstdcxx} == */libstdc++.so.* ]] || die "Cannot determine libstdc++ version"
		ver_test "${libstdcxx##*/libstdc++.so.}" -ge 6.0.32 \
			|| die "Aegisub requires libstdc++ 6.0.32 or newer (GCC or Clang)."
	fi
}

pkg_pretend() {
	aegisub_check_compiler
}

pkg_setup() {
	aegisub_check_compiler
	lua-single_pkg_setup
}

src_prepare() {
	default

	remove_locale() {
		sed -i -e "s/^${1}\(@latin\)\?//g" po/LINGUAS || die
		rm "po/${1}.po" || die
	}

	plocale_find_changes 'po' '' '.po'
	plocale_for_each_disabled_locale remove_locale
	# Upstream uses #ifdef for a Meson boolean, which can also be defined as 0.
	sed -i 's/^#ifdef WITH_UPDATE_CHECKER$/#if WITH_UPDATE_CHECKER == 1/' \
		src/dialog_version_check.cpp src/command/app.cpp src/main.cpp || die
	# Retain Gentoo's workaround for the ODR failure in bug #970232.
	filter-lto
}

src_configure() {
	tc-export PKG_CONFIG
	use debug && EMESON_BUILDTYPE=debug
	setup-wxwidgets
	local emesonargs=(
		-Denable_update_checker=false
		-Dffms2=enabled
		-Dsystem_luajit=true
		$(meson_use test tests)
		-Dlibportal=disabled
		$(meson_feature alsa)
		$(meson_feature fftw fftw3)
		$(meson_feature openal)
		$(meson_feature portaudio)
		$(meson_feature pulseaudio libpulse)
		$(meson_feature spell hunspell)
		$(meson_feature uchardet)
	)
	meson_src_configure
}

src_test() {
	# Run C++, LuaJIT compatibility, and parser recovery tests. Exclude the
	# automation suite, which needs a LuaRocks/Busted test environment.
	meson_src_test 'gtest main' luajit-52 'matroska recovery'
}
