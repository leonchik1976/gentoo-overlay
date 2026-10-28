# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
PYTHON_COMPAT=( python3_{13..15} )

inherit distutils-r1

DESCRIPTION="Python API for interacting with Glances"
HOMEPAGE="
	https://github.com/home-assistant-ecosystem/python-glances-api/
	https://pypi.org/project/glances-api/
"
SRC_URI="
	https://github.com/home-assistant-ecosystem/python-glances-api/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/python-${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/httpx-0.28[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-httpx )
distutils_enable_tests pytest
