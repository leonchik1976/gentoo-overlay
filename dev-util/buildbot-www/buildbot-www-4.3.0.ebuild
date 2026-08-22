# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: see dev-util/buildbot for context on why this was re-added.
# Upstream's www/base/setup.py declares install_requires=['buildbot'] and
# setup_requires=['buildbot_pkg']: buildbot_pkg is a build-time helper only
# (not imported by the installed buildbot_www code), while buildbot itself
# (buildbot.www.plugin.Application) is imported at runtime. The previous
# ::gentoo ebuild had this backwards (buildbot-pkg in RDEPEND, no RDEPEND
# on buildbot at all); fixed here to match upstream's actual import graph.

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..13} )
PYPI_PN=${PN/-/_}
inherit distutils-r1 pypi

DESCRIPTION="BuildBot base web interface, use with buildbot-{console-view,waterfall-view}..."
HOMEPAGE="https://buildbot.net/
	https://github.com/buildbot/buildbot
	https://pypi.org/project/buildbot-www/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~dev-util/buildbot-${PV}[${PYTHON_USEDEP}]"
BDEPEND="~dev-util/buildbot-pkg-${PV}[${PYTHON_USEDEP}]"

# Replaces the deprecated free-text license classifier with SPDX
# 'license_expression' metadata (matches LICENSE="GPL-2" above; setuptools
# QA warning "License classifiers are deprecated").
PATCHES=(
	"${FILESDIR}/${P}-setuptools-qa.patch"
)
