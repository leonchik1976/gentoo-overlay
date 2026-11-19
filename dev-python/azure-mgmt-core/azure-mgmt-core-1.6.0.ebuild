# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Microsoft Azure Management Core Library for Python"
HOMEPAGE="https://pypi.org/project/azure-mgmt-core/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/azure-core-1.32.0[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${P}-wheel-metadata.patch"
	"${FILESDIR}/${P}-requests-mock.patch"
)

BDEPEND+=" test? ( dev-python/requests-mock[${PYTHON_USEDEP}] )"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# The serialized poller token fixture predates the current Azure Core.
	tests/test_arm_polling.py::TestArmPolling::test_long_running_negative
)

python_test() {
	# Authentication and async integration tests use Azure SDK fixtures.
	epytest tests/test_{arm_endpoints,arm_polling,mgmt_exceptions,policies,tools}.py
}
