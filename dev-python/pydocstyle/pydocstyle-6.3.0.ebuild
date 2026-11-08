# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
EPYTEST_PLUGINS=()
# snowballstemmer does not yet provide free-threaded Python targets.
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Python docstring style checker"
HOMEPAGE="
	https://github.com/PyCQA/pydocstyle/
	https://pypi.org/project/pydocstyle/
"
# The PyPI sdist omits the tests.
SRC_URI="https://github.com/PyCQA/pydocstyle/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/snowballstemmer-2.2.0[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${P}-no-pip.patch"
	"${FILESDIR}/${P}-pep701.patch"
	"${FILESDIR}/${P}-imperative-test.patch"
)

distutils_enable_tests pytest

python_prepare_all() {
	# Upstream substitutes the release version only when publishing to PyPI.
	sed -i -e "s/0.0.0-dev/${PV}/" pyproject.toml || die
	distutils-r1_python_prepare_all
}
