# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..15} )
inherit distutils-r1 pypi

DESCRIPTION="Core library for Microsoft Azure Python SDKs"
HOMEPAGE="https://pypi.org/project/azure-core/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/requests-2.21.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.6.0[${PYTHON_USEDEP}]
"
BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"
