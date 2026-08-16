# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Adapted from ::gentoo's own dev-python/boltons-21.0.0-r1 (removed from
# the tree when boltons jumped straight from 21.0.0 to 23.0.0 upstream;
# last present at gentoo/gentoo@a99f69ebab). 21.0.0 remains upstream's
# only 21.x release (verified via PyPI release history), and is needed
# here only to satisfy dev-util/semgrep-bin's pinned
# boltons~=21.0 (>=21.0,<22) runtime requirement.
#
# PYTHON_COMPAT: upstream 21.0.0's own classifiers only declare Python
# 3.4-3.9 support (released 2021, predates 3.10+ entirely), and the
# original ::gentoo ebuild only ever enabled python3_{8..11}. The
# python3.10/python3.11-tests patches below are upstream/::gentoo's own
# fixes for that gap. python3_12/3_13/3_14 were not tested by upstream
# or ::gentoo, but the full test suite (389 tests) has been run and
# passes cleanly under all three here -- see the third patch below,
# needed for py3.12+'s removal of the legacy pytest_ignore_collect
# hookspec parameter that tests/conftest.py relied on.
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )
inherit distutils-r1

DESCRIPTION="Pure-python utilities in the same spirit as the standard library"
HOMEPAGE="https://boltons.readthedocs.org/"
SRC_URI="https://github.com/mahmoud/boltons/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

distutils_enable_tests pytest
distutils_enable_sphinx docs \
	dev-python/sphinx-rtd-theme

DOCS=( CHANGELOG.md README.md TODO.rst )

PATCHES=(
	"${FILESDIR}"/${P}-python3.10.patch
	"${FILESDIR}"/${P}-python3.11-tests.patch
	"${FILESDIR}"/${P}-pytest-ignore-collect-hookspec.patch
)

EPYTEST_DESELECT=(
	# fails if there's any noise/differences in traceback text caused
	# by e.g. pytest-qt noise or python3.11+ adding ^^^^^^ markers
	tests/test_tbutils.py::test_exception_info
)
