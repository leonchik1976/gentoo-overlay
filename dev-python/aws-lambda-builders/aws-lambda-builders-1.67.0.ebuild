# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# python3_15 intentionally not added yet: python-utils-r1.eclass already
# recognizes it as a valid target, and upstream 1.67.0's own
# Requires-Python (">=3.10") does not exclude it -- but ::gentoo has no
# final dev-lang/python-3.15 release (only 3.15.0_beta2..rc2/9999
# pre-releases, none installed on this host), so there is no interpreter
# here to actually build or test against. Untested, not unsupported;
# revisit once a stable dev-lang/python-3.15 exists.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Library to compile, build and package AWS Lambda functions"
HOMEPAGE="
	https://github.com/aws/aws-lambda-builders/
	https://pypi.org/project/aws-lambda-builders/
"
SRC_URI="https://github.com/aws/aws-lambda-builders/archive/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/parameterized[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Upstream verifies that an ordinary wheel build does not receive CC.
	unset CC
	epytest tests/unit
}
