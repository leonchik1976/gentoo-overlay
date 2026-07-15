# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Thin wrapper to run Terraform against LocalStack"
HOMEPAGE="
	https://github.com/localstack/terraform-local/
	https://pypi.org/project/terraform-local/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

RDEPEND+="
	app-admin/terraform
	dev-python/localstack-client[${PYTHON_USEDEP}]
	>=dev-python/python-hcl2-8[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	rm -f "${ED}"/usr/bin/tflocal.bat || die
}
