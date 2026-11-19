# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="SQLAlchemy database migrations for Flask applications using Alembic"
HOMEPAGE="https://pypi.org/project/Flask-Migrate/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/flask-0.9[${PYTHON_USEDEP}]
	>=dev-python/flask-sqlalchemy-1.0[${PYTHON_USEDEP}]
	>=dev-python/alembic-1.9.0[${PYTHON_USEDEP}]
"

BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/${P}-wheel-metadata.patch" )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# The tests invoke the Flask CLI as a subprocess.
	mkdir -p "${T}/bin" || die
	printf '#!/bin/sh\nexec "%s" -m flask "$@"\n' "${PYTHON}" > "${T}/bin/flask" || die
	chmod +x "${T}/bin/flask" || die
	PATH="${T}/bin:${PATH}" epytest tests
}
