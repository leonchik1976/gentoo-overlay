# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Standalone redistribution of the mailcap module removed from the stdlib"
HOMEPAGE="
	https://pypi.org/project/standard-mailcap/
	https://github.com/youknowone/python-deadlib/
"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

distutils_enable_tests unittest

BDEPEND+="
	test? (
		dev-python/test[${PYTHON_USEDEP}]
	)
"

python_prepare_all() {
	sed -i \
		-e 's/license = { text = "PSF-2.0" }/license = "PSF-2.0"/' \
		-e '/License :: OSI Approved :: Python Software Foundation License/d' \
		pyproject.toml || die

	# The sdist omits the test fixture listed in the upstream source tree.
	cp "${FILESDIR}"/mailcap.txt tests/ || die

	distutils-r1_python_prepare_all
}

python_test() {
	eunittest -s tests
}
