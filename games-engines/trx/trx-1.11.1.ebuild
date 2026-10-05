# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit desktop meson python-any-r1 xdg

DESCRIPTION="Reimplementation of the Tomb Raider I, II, III and IV engines"
HOMEPAGE="https://github.com/LostArtefacts/TRX"
SRC_URI="
	https://github.com/LostArtefacts/TRX/archive/refs/tags/${P}.tar.gz
	https://github.com/LostArtefacts/TRX/releases/download/${P}/TRX-${PV}-Linux.zip
"
S="${WORKDIR}/TRX-${P}"

LICENSE="GPL-3 LGPL-2.1+ ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-lang/lua:5.4
	dev-libs/libpcre2:=
	dev-libs/uthash
	media-libs/glew:=[-egl-only(-)]
	media-libs/libglvnd
	media-libs/libsdl2[joystick,opengl,sound,video]
	media-video/ffmpeg:=
	virtual/zlib:=
"
RDEPEND="
	dev-lang/lua:5.4
	dev-libs/libpcre2:=
	media-libs/glew:=[-egl-only(-)]
	media-libs/libglvnd
	media-libs/libsdl2[joystick,opengl,sound,video]
	media-video/ffmpeg:=
	virtual/zlib:=
"
BDEPEND="${BDEPEND}
	${PYTHON_DEPS}
	>=dev-build/meson-1.3.0
	app-arch/unzip
	virtual/pkgconfig
"

EMESON_SOURCE="${S}/src"

src_prepare() {
	default
	sed -e "s|@EPREFIX@|${EPREFIX}|g" "${FILESDIR}/trx" > "${T}/trx" || die
}

src_configure() {
	local emesonargs=(
		-Dlua_dep=lua5.4
		-Dstaticdeps=false
		-Dtrx_version=${PV}
	)
	meson_src_configure
	if use test; then
		local emesonargs=()
		EMESON_SOURCE="${S}/src/tests" BUILD_DIR="${WORKDIR}/tests-build" meson_src_configure
	fi
}

src_compile() {
	meson_src_compile
	if use test; then
		BUILD_DIR="${WORKDIR}/tests-build" meson_src_compile
	fi
}

src_test() {
	BUILD_DIR="${WORKDIR}/tests-build" meson_src_test
}

src_install() {
	# Compile the executable from source. Only runtime assets come from the release ZIP.
	exeinto /usr/libexec/trx
	doexe "${BUILD_DIR}/TRX"
	dobin "${T}/trx"
	insinto /usr/share/trx
	doins -r "${WORKDIR}"/{cfg,games,modules,scripts}
	newicon -s 256 data/trx/icon.png trx.png
	make_desktop_entry trx TRX trx Game
	dodoc COPYING.md src/trx/av/{video.c,audio_reverb.c}
	dodoc README.md "${FILESDIR}/README.gentoo" docs/trx/INSTALLING.md
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Copy the shipped support assets and your original Tomb Raider game data"
	elog "into your user directories before running trx. See README.gentoo in"
	elog "${EPREFIX}/usr/share/doc/${PF} for setup and upgrade instructions."
}
