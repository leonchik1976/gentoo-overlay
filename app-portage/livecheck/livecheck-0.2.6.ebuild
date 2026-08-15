# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Tool for overlays to detect and apply ebuild version updates"
HOMEPAGE="
	https://github.com/Tatsh/livecheck/
	https://pypi.org/project/livecheck/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/anyio-4.14.2[${PYTHON_USEDEP}]
	>=dev-python/bascom-0.1.3[${PYTHON_USEDEP}]
	>=dev-python/beautifulsoup4-4.15.0[${PYTHON_USEDEP}]
	>=dev-python/click-8.4.2[${PYTHON_USEDEP}]
	>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/html5lib-1.1[${PYTHON_USEDEP}]
	>=dev-python/keyring-25.7.0[${PYTHON_USEDEP}]
	>=dev-python/niquests-3.20.1[${PYTHON_USEDEP}]
	>=dev-python/niquests-cache-0.2.4[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.11.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.16.0[${PYTHON_USEDEP}]
	>=sys-apps/portage-3.0.81.2[${PYTHON_USEDEP}]
"
BDEPEND+="
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		>=dev-python/niquests-mock-0.5.0[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-mock )
distutils_enable_tests pytest

python_install_all() {
	doman man/livecheck.1
	distutils-r1_python_install_all
}
