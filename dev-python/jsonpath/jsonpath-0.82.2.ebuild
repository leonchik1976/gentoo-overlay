# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="XPath-like expressions for JSON"
HOMEPAGE="
	https://www.ultimate.com/phil/python/#jsonpath
	https://pypi.org/project/jsonpath/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest test/test*.py
}
