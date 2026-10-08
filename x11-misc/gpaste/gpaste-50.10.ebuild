# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_USE_DEPEND="vapigen"
inherit gnome2-utils meson vala xdg

DESCRIPTION="Clipboard management system"
HOMEPAGE="https://github.com/Keruspe/GPaste"
SRC_URI="https://github.com/Keruspe/GPaste/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/GPaste-${PV}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+gnome +introspection systemd vala wayland"
REQUIRED_USE="
	gnome? ( introspection )
	vala? ( introspection )
"

DEPEND="
	>=app-crypt/gcr-3.90.0:4=
	>=dev-libs/glib-2.84.0:2
	>=gui-libs/gtk-4.18.0:4[X,introspection?,wayland=]
	>=gui-libs/libadwaita-1.9:1[introspection?]
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/pango
	gnome? (
		>=gnome-base/gnome-shell-50
		<gnome-base/gnome-shell-51
	)
	introspection? ( dev-libs/gobject-introspection:= )
"
RDEPEND="${DEPEND}
	app-text/wgetpaste
"
BDEPEND+="
	dev-util/glib-utils
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	use vala && vala_setup
	xdg_environment_reset

	# The optional lint test runs npm clean-install, requiring network access.
	sed -i "s/find_program('npm', required: false)/disabler()/" \
		src/gnome-shell/meson.build || die
}

src_configure() {
	local emesonargs=(
		-Dbash-completion=true
		-Dzsh-completion=true
		-Dx-keybinder=true
		-Ddbus-services-dir="${EPREFIX}/usr/share/dbus-1/services"
		-Dcontrol-center-keybindings-dir="${EPREFIX}/usr/share/gnome-control-center/keybindings"
		-Dsystemd-user-unit-dir="${EPREFIX}/usr/lib/systemd/user"
		$(meson_use gnome gnome-shell)
		$(meson_use introspection)
		$(meson_use systemd)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
