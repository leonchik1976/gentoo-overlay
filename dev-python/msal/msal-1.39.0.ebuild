# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="Microsoft Authentication Library for Python"
HOMEPAGE="https://pypi.org/project/msal/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-1.0.0[${PYTHON_USEDEP}]
	<dev-python/pyjwt-3[${PYTHON_USEDEP}]
	>=dev-python/cryptography-2.5[${PYTHON_USEDEP}]
	<dev-python/cryptography-51[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/${P}-wheel-metadata.patch" )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Other modules import omitted helpers or require external endpoints.
	epytest tests/test_{cloudshell,individual_cache,optional_thumbprint}.py
}
