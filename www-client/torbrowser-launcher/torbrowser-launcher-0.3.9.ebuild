# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 and xdg do not support EAPI 9 yet.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 xdg

DESCRIPTION="Download, verify and launch Tor Browser Alpha on arm64"
HOMEPAGE="https://gitlab.torproject.org/tpo/applications/torbrowser-launcher"
SRC_URI="https://gitlab.torproject.org/tpo/applications/torbrowser-launcher/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="MIT"
SLOT="0"
# Explicit arm64-only local variant; amd64 users can use ::guru.
KEYWORDS="~arm64"

# The launcher downloads the browser at user runtime, never during the build.
RDEPEND+="
	app-accessibility/at-spi2-core:2
	app-crypt/gnupg
	dev-libs/glib:2
	dev-python/gpgmepy[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pyside:6[core,gui,widgets,${PYTHON_USEDEP}]
	dev-python/pysocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	sys-apps/dbus
	virtual/freedesktop-icon-theme
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/pango
	|| (
		media-libs/libpulse
		media-sound/apulse
	)
"
BDEPEND+="
	dev-python/distro[${PYTHON_USEDEP}]
	sys-devel/gettext
"

PATCHES=(
	"${FILESDIR}/${PN}-0.3.9-aarch64-alpha.patch"
	"${FILESDIR}/${PN}-0.3.9-apparmor-install.patch"
)

distutils_enable_tests import-check

python_prepare_all() {
	# Identify the alpha channel in desktop menus, including translated names.
	sed -i '/^Name\(\[.*\]\)\?=/s/$/ (Alpha)/' \
		share/applications/*.desktop || die

	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /etc/apparmor.d
	doins apparmor/torbrowser.*
	insinto /etc/apparmor.d/local
	doins apparmor/local/torbrowser.*
	insinto /etc/apparmor.d/tunables
	doins apparmor/tunables/torbrowser
}

pkg_postinst() {
	xdg_pkg_postinst

	ewarn "This local arm64 variant downloads Tor Browser Alpha, not stable."
	ewarn "Upstream does not yet support arm64 in torbrowser-launcher 0.3.9."
	elog "The browser is downloaded and signature-verified on first launch."
	elog "Its files and updates are managed in your user account, outside Portage."
	elog "Downloading over Tor needs a running SOCKS proxy (default 127.0.0.1:9050)."
}
