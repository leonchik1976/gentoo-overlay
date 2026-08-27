# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="File browser for Cockpit"
HOMEPAGE="https://github.com/cockpit-project/cockpit-files"
SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=app-admin/cockpit-318"
BDEPEND="sys-devel/gettext"

src_compile() { :; }

src_install() {
	# Upstream's install target also merges po/*.po into AppStream metadata.
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
