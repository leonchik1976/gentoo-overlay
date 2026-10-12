# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1.eclass currently supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="MinIO Python SDK for S3-compatible object storage"
HOMEPAGE="https://github.com/minio/minio-py https://pypi.org/project/minio/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/argon2-cffi[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/${P}-setuptools-metadata.patch" )
DOCS=( README.md README_zh_CN.md NOTICE )

distutils_enable_tests unittest

python_test() {
	# Upstream unit tests use *_test.py names and mocked HTTP connections.
	# Functional tests require a live S3 server and are not run here.
	eunittest -s tests -p '*_test.py'
}
