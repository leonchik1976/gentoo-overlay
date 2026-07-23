# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Install and Run Python Applications in Isolated Environments"
HOMEPAGE="
	https://pipx.pypa.io/stable/
	https://pypi.org/project/pipx/
	https://github.com/pypa/pipx/
"
# no tests in sdist
SRC_URI="https://github.com/pypa/pipx/archive/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="uv"

# Upstream tests require a large, version-specific offline wheel cache.
# Maintaining that cache is impractical; see Gentoo bug 971387.
RESTRICT="test"

RDEPEND="
	>=dev-python/argcomplete-1.9.4[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.16[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.6[${PYTHON_USEDEP}]
	>=dev-python/userpath-1.6[${PYTHON_USEDEP}]
	uv? ( >=dev-python/uv-0.9.17 )
"
BDEPEND="
	>=dev-python/docutils-0.21[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
