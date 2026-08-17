# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Command line tool to select files out of bash output"
HOMEPAGE="https://github.com/facebook/PathPicker"
SRC_URI="https://github.com/facebook/PathPicker/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/PathPicker-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# IndexError: list index out of range
	src/tests/test_screen.py::TestScreenLogic::test_screen_inputs
)

python_prepare_all() {
	# Upstream's own version declarations are stuck at 0.9.2 despite this
	# being the 0.9.5 release tag; fix both the installed package metadata
	# and the string `fpp --version` actually prints at runtime. Must run
	# here (not a plain src_prepare) since python_prepare_all() is what
	# runs once in ${S} before distutils-r1 forks the per-implementation
	# build directories from it.
	sed -i -e "s/^version = \"0\.9\.2\"/version = \"${PV}\"/" pyproject.toml || die
	sed -i -e "s/^VERSION = \"0\.9\.2\"/VERSION = \"${PV}\"/" src/version.py || die

	distutils-r1_python_prepare_all
}

src_install() {
	distutils-r1_src_install

	insinto /usr/share/fpp/src
	doins src/{choose,print_help,process_input,version}.py
	insinto /usr/share/fpp
	doins fpp
	fperms +x /usr/share/fpp/fpp
	dosym ../share/fpp/fpp usr/bin/fpp
	doman debian/usr/share/man/man1/fpp.1
}
