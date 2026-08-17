# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="AWS Encryption SDK implementation for Python"
HOMEPAGE="
	https://pypi.org/project/aws-encryption-sdk/
	https://github.com/aws/aws-encryption-sdk-python/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/boto3[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/wrapt[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-mock )
distutils_enable_tests pytest

BDEPEND+="
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# Require network access and AWS credentials.
	test/integration

	# Require the unpackaged aws-cryptographic-material-providers.
	test/mpl

	# Integration examples requiring AWS services or MPL.
	examples/test
)

python_prepare_all() {
	# Obsolete for Python 3-only packages and deprecated by wheel.
	sed -i -e '/^\[wheel\]$/,+1d' setup.cfg || die

	distutils-r1_python_prepare_all
}

python_test() {
	# Prevent boto3 from probing EC2 instance metadata for credentials.
	export AWS_EC2_METADATA_DISABLED=true

	distutils-r1_python_test
}
