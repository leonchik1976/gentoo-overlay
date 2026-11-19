# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Add SQLAlchemy support to your Flask application"
HOMEPAGE="https://pypi.org/project/Flask-SQLAlchemy/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/flask-2.2.5[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-2.0.16[${PYTHON_USEDEP}]
"
