# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual machine management for Cockpit"
HOMEPAGE="https://github.com/cockpit-project/cockpit-machines"
SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="spice"

RDEPEND="
	app-admin/cockpit
	>=app-emulation/libvirt-3.0.0[qemu]
	>=app-emulation/libvirt-dbus-1.2.0
	>=app-emulation/virt-manager-3.0.0
	app-emulation/qemu
	spice? ( app-emulation/qemu[spice] )
"
BDEPEND="sys-devel/gettext"

src_compile() { :; }

src_install() {
	# Upstream's install target also merges po/*.po into AppStream metadata.
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
