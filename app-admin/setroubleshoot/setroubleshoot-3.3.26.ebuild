# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

# This SELinux-specific package is intentionally untested.

inherit autotools python-single-r1

DESCRIPTION="SELinux alert browser and troubleshooting daemon"
HOMEPAGE="https://github.com/fedora-selinux/setroubleshoot"
SRC_URI="https://github.com/fedora-selinux/setroubleshoot/archive/refs/tags/setroubleshoot-${PV}.tar.gz"
S="${WORKDIR}/setroubleshoot-setroubleshoot-${PV}/framework"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	sys-libs/libcap-ng
	$(python_gen_cond_dep '
		app-admin/setools[${PYTHON_USEDEP}]
		dev-libs/libxml2:2[python,${PYTHON_USEDEP}]
		dev-python/dasbus[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		sys-apps/policycoreutils[${PYTHON_USEDEP}]
		sys-libs/libselinux[python,${PYTHON_USEDEP}]
		sys-process/audit[python,${PYTHON_USEDEP}]
	')
	x11-libs/gtk+:3[introspection]
	x11-libs/libnotify[introspection]
	x11-misc/xdg-utils
"
DEPEND="
	${RDEPEND}
	sys-apps/dbus
"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	python_fix_shebang src
	eautoreconf
}

src_configure() {
	econf \
		--disable-seappletlegacy \
		--with-auditpluginsdir="${EPREFIX}/etc/audit/plugins.d"
}

src_test() {
	emake check PYTHON="${EPYTHON}"
}

src_install() {
	emake DESTDIR="${D}" PYTHON="${EPYTHON}" install
	python_optimize
	find "${ED}" -type f -name '*.la' -delete || die
}
