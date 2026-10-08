# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
VALA_USE_DEPEND="vapigen"
inherit gnome2-utils meson python-any-r1 vala xdg

DESCRIPTION="Clipboard management system"
HOMEPAGE="https://github.com/Keruspe/GPaste"
SRC_URI="https://github.com/Keruspe/GPaste/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/GPaste-${PV}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="crypt +gnome +introspection keyring pwquality sqlite systemd test vala"
REQUIRED_USE="
	gnome? ( introspection )
	keyring? ( crypt )
	vala? ( introspection )
"
RESTRICT="!test? ( test )"

DEPEND="
	>=app-crypt/gcr-4.0.0:4=
	>=dev-libs/glib-2.89.0:2
	>=gui-libs/gtk-4.23.4:4[X,introspection?]
	>=gui-libs/libadwaita-1.10_alpha:1[introspection?]
	sys-apps/dbus
	x11-libs/pango
	crypt? ( dev-libs/libsodium:= )
	gnome? (
		>=gnome-base/gnome-shell-51
		<gnome-base/gnome-shell-52
		>=x11-wm/mutter-51:0=[introspection]
		<x11-wm/mutter-52
	)
	introspection? ( dev-libs/gobject-introspection:= )
	keyring? ( app-crypt/libsecret )
	pwquality? ( dev-libs/libpwquality )
	sqlite? ( >=dev-db/sqlite-3.35:3 )
"
RDEPEND="${DEPEND}
	net-misc/curl
"
BDEPEND+="
	${PYTHON_DEPS}
	dev-util/glib-utils
	sys-devel/gettext
	virtual/pkgconfig
	test? (
		net-libs/nodejs
		x11-base/xorg-server[xvfb]
	)
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
		-Dfish-completion=true
		-Dzsh-completion=true
		-Ddbus-services-dir="${EPREFIX}/usr/share/dbus-1/services"
		-Ddbus-interfaces-dir="${EPREFIX}/usr/share/dbus-1/interfaces"
		-Dcontrol-center-keybindings-dir="${EPREFIX}/usr/share/gnome-control-center/keybindings"
		-Dsystemd-user-unit-dir="${EPREFIX}/usr/lib/systemd/user"
		$(meson_feature crypt encryption)
		$(meson_feature keyring libsecret)
		$(meson_feature pwquality)
		$(meson_feature sqlite)
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
