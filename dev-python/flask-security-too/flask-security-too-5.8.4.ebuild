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

BDEPEND+="
	test? (
		dev-python/authlib[${PYTHON_USEDEP}]
		dev-python/flask-mail[${PYTHON_USEDEP}]
		dev-python/flask-sqlalchemy[${PYTHON_USEDEP}]
		dev-python/freezegun[${PYTHON_USEDEP}]
		dev-python/phonenumbers[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# Registration deliverability checking queries DNS.
	tests/test_misc.py::test_login_email_whatever
	# Earlier tests populate the shared RegisterForm username field.
	tests/test_registerable.py::test_username_not_enabled
)

python_test() {
	# The MongoDB cases require mongomock or a separate MongoDB instance.
	epytest -k 'not cl-mongo and not mongoengine'
}
