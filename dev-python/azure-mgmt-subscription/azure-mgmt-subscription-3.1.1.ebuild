# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Microsoft Azure Subscription Management Client Library for Python"
HOMEPAGE="https://pypi.org/project/azure-mgmt-subscription/"

SRC_URI="$(pypi_sdist_url --no-normalize "${PN}" "${PV}" .zip)"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/msrest-0.7.1[${PYTHON_USEDEP}]
	>=dev-python/azure-common-1.1[${PYTHON_USEDEP}]
	>=dev-python/azure-mgmt-core-1.3.2[${PYTHON_USEDEP}]
	<dev-python/azure-mgmt-core-2[${PYTHON_USEDEP}]
"

BDEPEND+=" app-arch/unzip"

PATCHES=( "${FILESDIR}/${P}-wheel-metadata.patch" )

# The sole suite requires the Azure recording proxy and its SDK test harness.
RESTRICT="test"
