# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="D-Bus API binding for libvirt"
HOMEPAGE="https://libvirt.org/ https://github.com/libvirt/libvirt-dbus"
SRC_URI="https://github.com/libvirt/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=app-emulation/libvirt-3.0.0
	>=app-emulation/libvirt-glib-0.0.7
	>=dev-libs/glib-2.44
	sys-apps/systemd
	sys-auth/polkit
"
DEPEND="${RDEPEND}"

src_configure() {
	local emesonargs=(
		-Dinit_script=systemd
		-Dgit_werror=disabled
	)
	meson_src_configure
}
