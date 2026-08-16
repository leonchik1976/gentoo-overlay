# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Python module for reading ISC dhcpd lease files"
HOMEPAGE="
	https://github.com/MartijnBraam/python-isc-dhcp-leases/
	https://pypi.org/project/isc-dhcp-leases/
"
SRC_URI="
	https://github.com/MartijnBraam/python-isc-dhcp-leases/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/python-${P}

PATCHES=(
	"${FILESDIR}/${P}-setup-metadata.patch"
)

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/six[${PYTHON_USEDEP}]"
BDEPEND="
	test? ( >=dev-python/freezegun-0.3.4[${PYTHON_USEDEP}] )
"

distutils_enable_tests pytest
