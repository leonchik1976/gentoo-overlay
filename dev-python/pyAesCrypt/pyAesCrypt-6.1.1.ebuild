# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_PN=pyAesCrypt
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Encrypt and decrypt files and streams in AES Crypt format"
HOMEPAGE="
	https://github.com/marcobellaccini/pyAesCrypt/
	https://pypi.org/project/pyAesCrypt/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/cryptography[${PYTHON_USEDEP}]"

PATCHES=(
	"${FILESDIR}/${P}-skip-external-aescrypt-tests.patch"
)

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" -m unittest pyAesCrypt.test_crypto || die
}
