# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Self-contained Python driver for communicating with MySQL servers"
HOMEPAGE="
	https://dev.mysql.com/doc/connector-python/en/
	https://github.com/mysql/mysql-connector-python/
	https://pypi.org/project/mysql-connector-python/
"
SRC_URI="
	https://github.com/mysql/mysql-connector-python/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${P}/${PN}"

LICENSE="GPL-2-with-Universal-FOSS-exception"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=(
	"${FILESDIR}/${P}-drop-license-classifier.patch"
)

DOCS=(
	"${WORKDIR}/${P}"/{CHANGES.txt,README.rst,README.txt}
)

distutils_enable_tests unittest

python_test() {
	# The complete upstream suite bootstraps several MySQL server instances.
	# Run the server-independent unit tests here.
	local test
	for test in errorcode errors locales protocol utils; do
		eunittest -s tests -p "test_${test}.py" -t .
	done
}
