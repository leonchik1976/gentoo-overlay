# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# New package: not present in ::gentoo. Needed as a hard (unconditional
# install_requires) runtime dependency of dev-python/glom, which is
# itself needed by dev-util/semgrep-bin. ::nest carries an older
# face-24.0.0 (pre-flit_core migration); this uses the current upstream
# 26.0.1 release and its current PEP517 metadata instead.
DISTUTILS_USE_PEP517=flit-core
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="A command-line application framework (and CLI parser)"
HOMEPAGE="
	https://github.com/mahmoud/face/
	https://pypi.org/project/face/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/boltons-20.0.0[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
