# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
PYPI_PN="Flask-Principal"
PYPI_NO_NORMALIZE=1
inherit distutils-r1 pypi

DESCRIPTION="Identity management for flask"
HOMEPAGE="https://pypi.org/project/Flask-Principal/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/blinker[${PYTHON_USEDEP}]
"
