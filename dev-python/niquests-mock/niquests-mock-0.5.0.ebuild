# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="HTTP mocking library and pytest plugin for niquests"
HOMEPAGE="
	https://github.com/0x12th/niquests-mock/
	https://pypi.org/project/niquests-mock/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/niquests-3.17.0[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/${P}-stdlib-json.patch" )

# The PyPI sdist does not contain upstream's tests.
distutils_enable_tests import-check
