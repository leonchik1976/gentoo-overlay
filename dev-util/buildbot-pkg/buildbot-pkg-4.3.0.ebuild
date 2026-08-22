# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: see dev-util/buildbot for context on why this was re-added.

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..13} )
PYPI_PN=${PN/-/_}
inherit distutils-r1 pypi

DESCRIPTION="BuildBot common www build tools for packaging releases"
HOMEPAGE="https://buildbot.net/
	https://github.com/buildbot/buildbot
	https://pypi.org/project/buildbot-pkg/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# No real integration tests for this pkg.
# all tests are related to making releases and final checks for distribution
RESTRICT="test"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# Replaces the deprecated free-text license classifier with SPDX
# 'license_expression' metadata (matches LICENSE="GPL-2" above; setuptools
# QA warning "License classifiers are deprecated").
PATCHES=(
	"${FILESDIR}/${P}-setuptools-qa.patch"
)

src_prepare() {
	sed -e "/version/s/=.*$/=\"${PV/_p/.post}\",/" -i setup.py || die
	distutils-r1_src_prepare
}
