# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: see dev-util/buildbot-www for the RDEPEND/BDEPEND split rationale.
# Upstream's www/badges/setup.py declares
# install_requires=['klein', 'CairoSVG', 'cairocffi', 'Jinja2'].

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..13} )
PYPI_PN=${PN//-/_}
inherit distutils-r1 pypi

DESCRIPTION="Buildbot badges plugin produces an image in SVG or PNG format showing status"
HOMEPAGE="https://buildbot.net/
	https://github.com/buildbot/buildbot
	https://pypi.org/project/buildbot-badges/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	~dev-util/buildbot-www-${PV}[${PYTHON_USEDEP}]
	dev-python/cairocffi[${PYTHON_USEDEP}]
	media-gfx/cairosvg[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/klein[${PYTHON_USEDEP}]
"
BDEPEND="~dev-util/buildbot-pkg-${PV}[${PYTHON_USEDEP}]"
