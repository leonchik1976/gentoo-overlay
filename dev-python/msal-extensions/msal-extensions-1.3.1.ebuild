# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="Persistent token cache extensions for MSAL"
HOMEPAGE="https://pypi.org/project/msal-extensions/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/msal-1.29[${PYTHON_USEDEP}]
	<dev-python/msal-2[${PYTHON_USEDEP}]
	dev-python/portalocker[${PYTHON_USEDEP}]
"
