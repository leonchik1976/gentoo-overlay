# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

# This SELinux-specific package is intentionally untested.

inherit autotools python-single-r1

DESCRIPTION="Analysis plugins for setroubleshoot"
HOMEPAGE="https://github.com/fedora-selinux/setroubleshoot"
SRC_URI="https://github.com/fedora-selinux/setroubleshoot/archive/refs/tags/setroubleshoot-plugins-${PV}.tar.gz"
S="${WORKDIR}/setroubleshoot-setroubleshoot-plugins-${PV}/plugins"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	~app-admin/setroubleshoot-3.3.26
	$(python_gen_cond_dep '
		app-admin/setools[${PYTHON_USEDEP}]
		sys-apps/policycoreutils[${PYTHON_USEDEP}]
		sys-libs/libselinux[python,${PYTHON_USEDEP}]
	')
"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
"

src_prepare() {
	default
	python_fix_shebang src
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" PYTHON="${EPYTHON}" install
	python_optimize
}
