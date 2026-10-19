# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Retry client for aiohttp"
HOMEPAGE="https://github.com/inyutin/aiohttp_retry https://pypi.org/project/aiohttp-retry/"
# The PyPI sdist omits tests/app.py; use the complete tagged source.
SRC_URI="https://github.com/inyutin/aiohttp_retry/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/aiohttp_retry-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="dev-python/aiohttp[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=( pytest-aiohttp pytest-asyncio )
distutils_enable_tests pytest

python_prepare_all() {
	# The v2.9.1 tag still declares 2.9.0; match the released package version.
	sed -e "s/version=\"2[.]9[.]0\"/version=\"${PV}\"/" -i setup.py || die
	grep -Fq "    version=\"${PV}\"," setup.py || die "Incorrect source version"

	distutils-r1_python_prepare_all
}
