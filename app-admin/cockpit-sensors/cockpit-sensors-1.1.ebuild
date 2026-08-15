# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Hardware sensor monitoring page for Cockpit"
HOMEPAGE="https://github.com/ocristopfer/cockpit-sensors"
SRC_URI="https://github.com/ocristopfer/${PN}/releases/download/${PV}/${PN}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="LGPL-2.1+ MIT CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# Tests require Cockpit's external VM/browser integration environment.
RESTRICT="test"

RDEPEND="
	>=app-admin/cockpit-137
	sys-apps/lm-sensors
"
BDEPEND="sys-devel/gettext"

src_compile() { :; }

src_install() {
	# This installs the release bundle and merges po/*.po into AppStream data.
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	dodoc README.md
}
