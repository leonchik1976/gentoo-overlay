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

BDEPEND+=" test? ( dev-python/pytest-asyncio[${PYTHON_USEDEP}] )"

EPYTEST_PLUGINS=( pytest-asyncio )
EPYTEST_IGNORE=( tests/test_benchmarks.py )
distutils_enable_tests pytest
