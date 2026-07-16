# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Identify devices and capabilities from browser user agents"
HOMEPAGE="
	https://github.com/selwin/python-user-agents/
	https://pypi.org/project/user-agents/
"
SRC_URI="
	https://github.com/selwin/python-user-agents/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S=${WORKDIR}/python-${P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=dev-python/ua-parser-0.10.0[${PYTHON_USEDEP}]"

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" -m unittest user_agents.tests || die
}
