# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Simple wrapper around AWS SAM CLI for use with LocalStack"
HOMEPAGE="
	https://github.com/localstack/aws-sam-cli-local/
	https://pypi.org/project/aws-sam-cli-local/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-admin/aws-sam-cli[${PYTHON_USEDEP}]
	dev-python/boto3[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	rm -f "${ED}"/usr/bin/samlocal.bat || die
}
