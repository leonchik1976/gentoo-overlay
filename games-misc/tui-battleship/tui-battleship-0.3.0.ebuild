# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="TUI implementation of the classic Battleship game, written in Bash"
HOMEPAGE="https://gitlab.com/christosangel/tui-battleship"
SRC_URI="https://gitlab.com/christosangel/${PN}/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# notify-send is called unconditionally on a missing/malformed config file,
# and the packaged default config also enables NOTIFICATION_TOGGLE.
RDEPEND="x11-libs/libnotify"

PATCHES=( "${FILESDIR}/${P}-xdg-paths.patch" )

src_prepare() {
	default

	# The patch leaves a @GENTOO_EPREFIX@ placeholder in ASSET_DIR so the
	# installed script keeps working under Gentoo Prefix; resolve it here
	# rather than shipping an unresolved variable in the runtime script.
	sed -i -e "s|@GENTOO_EPREFIX@|${EPREFIX}|" "${S}"/tui-battleship.sh || die
}

src_install() {
	newbin tui-battleship.sh tui-battleship

	insinto /usr/share/tui-battleship
	doins tui-battleship-dark.png tui-battleship-light.png
	doins "${FILESDIR}"/tui-battleship.config

	dodoc README.md
}
