# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Date parsing library designed to parse dates from HTML pages"
HOMEPAGE="
	https://dateparser.readthedocs.io/
	https://github.com/scrapinghub/dateparser/
	https://pypi.org/project/dateparser/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/tzlocal[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/convertdate[${PYTHON_USEDEP}]
		dev-python/hijridate[${PYTHON_USEDEP}]
		dev-python/langdetect[${PYTHON_USEDEP}]
		dev-python/parameterized[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local -x TZ=UTC

	local EPYTEST_IGNORE=(
		# requires upstream data-generation inputs absent from the PyPI sdist
		tests/test_dateparser_data_integrity.py
	)

	epytest
}

pkg_postinst() {
	optfeature "non-Gregorian calendar support" \
		dev-python/convertdate dev-python/hijridate
	optfeature "automatic language detection" dev-python/langdetect
}
