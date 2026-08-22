# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: see dev-util/buildbot-www for the RDEPEND/BDEPEND split rationale.

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..13} )
PYPI_PN=${PN//-/_}
inherit distutils-r1 pypi

DESCRIPTION="Buildbot plugin to integrate flask or bottle dashboards into the web UI"
HOMEPAGE="https://buildbot.net/
	https://github.com/buildbot/buildbot
	https://pypi.org/project/buildbot-wsgi-dashboards/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~dev-util/buildbot-www-${PV}[${PYTHON_USEDEP}]"
BDEPEND="~dev-util/buildbot-pkg-${PV}[${PYTHON_USEDEP}]"

# Replaces the deprecated free-text license classifier with SPDX
# 'license_expression' metadata (matches LICENSE="GPL-2" above; setuptools
# QA warning "License classifiers are deprecated").
PATCHES=(
	"${FILESDIR}/${P}-setuptools-qa.patch"
)
