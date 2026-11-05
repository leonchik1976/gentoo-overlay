# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} python3_15t )
inherit distutils-r1 pypi

DESCRIPTION="Thread-safe asyncio-aware queue for Python"
HOMEPAGE="https://github.com/aio-libs/janus"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+="
	>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
	test? ( dev-python/pytest-asyncio[${PYTHON_USEDEP}] )
"

PATCHES=( "${FILESDIR}/${P}-spdx-license.patch" )

EPYTEST_PLUGINS=( pytest-asyncio )
EPYTEST_IGNORE=( tests/test_benchmarks.py )
distutils_enable_tests pytest
