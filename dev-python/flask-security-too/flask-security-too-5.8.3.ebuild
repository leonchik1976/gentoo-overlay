# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Quickly add security features to your Flask application"
HOMEPAGE="https://pypi.org/project/Flask-Security-Too/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/flask-3.1.1[${PYTHON_USEDEP}]
	>=dev-python/flask-login-0.6.3[${PYTHON_USEDEP}]
	>=dev-python/flask-principal-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/flask-wtf-1.1.2[${PYTHON_USEDEP}]
	>=dev-python/email-validator-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/markupsafe-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/libpass-1.9.3[${PYTHON_USEDEP}]
	>=dev-python/wtforms-3.0.0[${PYTHON_USEDEP}]
"
