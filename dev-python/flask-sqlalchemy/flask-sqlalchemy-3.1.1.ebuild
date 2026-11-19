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

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local options=(
		# These release fixtures use utcnow() and leave SQLite engines open.
		-W 'ignore:datetime.datetime.utcnow:DeprecationWarning'
		-W 'ignore:unclosed database:ResourceWarning'
	)
	if has_version '>=dev-python/sqlalchemy-2.1'; then
		# SQLAlchemy 2.1 rejects the release's mapped-dataclass fixtures.
		options+=( -k 'not model_class2 and not model_class4 and not db2 and not db4' )
		EPYTEST_DESELECT+=(
			tests/test_model.py::test_declarativebasemapped_2x
			tests/test_model.py::test_declarativebasenometamapped_2x
		)
	fi
	epytest "${options[@]}"
}
