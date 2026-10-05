# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake gnome2-utils xdg

DESCRIPTION="Nine Men's Morris board game with rule variants and a learning AI"
HOMEPAGE="https://nine-mens-morris.net/ https://github.com/farindk/morris"
SRC_URI="https://github.com/farindk/morris/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+nls test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:3
	nls? ( virtual/libintl )
"
RDEPEND="${DEPEND}"
BDEPEND="${BDEPEND}
	dev-libs/glib:2
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DENABLE_NLS=$(usex nls)
		-DMORRIS_COMPILE_SCHEMAS=OFF
	)
	cmake_src_configure
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_pkg_postrm
}
