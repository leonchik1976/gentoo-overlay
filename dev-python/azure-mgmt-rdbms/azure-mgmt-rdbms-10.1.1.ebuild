# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Microsoft Azure Rdbms Management Client Library for Python"
HOMEPAGE="https://pypi.org/project/azure-mgmt-rdbms/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/msrest-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/azure-mgmt-core-1.6.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.6.0[${PYTHON_USEDEP}]
"

BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# The disabled CLI suites create real Azure database servers. Run the
	# independent import test explicitly because its filename is disabled too.
	epytest tests/disable_test_import.py
}
