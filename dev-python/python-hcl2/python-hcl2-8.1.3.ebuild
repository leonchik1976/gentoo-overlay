# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

inherit distutils-r1

DESCRIPTION="Parser for HashiCorp Configuration Language v2"
HOMEPAGE="
	https://github.com/amplify-education/python-hcl2/
	https://pypi.org/project/python-hcl2/
"
SRC_URI="
	https://github.com/amplify-education/python-hcl2/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=dev-python/lark-1.1.5[${PYTHON_USEDEP}]
	<dev-python/lark-2[${PYTHON_USEDEP}]
	>=dev-python/regex-2024.4.16[${PYTHON_USEDEP}]
"
BDEPEND+="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest -qq
}
