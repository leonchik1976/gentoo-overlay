# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python log in json format"
HOMEPAGE="https://pypi.org/project/jsonformatter/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/${P}-wheel-metadata.patch" )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# The sdist omits tests/logger_config.ini.
	tests/test.py::JsonFormatterTest::test_file_config
)

python_test() {
	epytest tests/test.py
}
