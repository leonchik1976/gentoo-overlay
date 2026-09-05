# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="HTTP/1.1, HTTP/2 and HTTP/3 client with sync and async APIs"
HOMEPAGE="
	https://github.com/jawah/urllib3.future/
	https://pypi.org/project/urllib3-future/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/h11-0.11.0[${PYTHON_USEDEP}]
	<dev-python/h11-1[${PYTHON_USEDEP}]
	>=dev-python/jh2-5.0.3[${PYTHON_USEDEP}]
	<dev-python/jh2-6[${PYTHON_USEDEP}]
	>=dev-python/qh3-1.5.4[${PYTHON_USEDEP}]
	<dev-python/qh3-3[${PYTHON_USEDEP}]
"

# Upstream explicitly requires distribution packagers to disable its
# urllib3 replacement mode.  This installs the fork as urllib3_future and
# avoids colliding with dev-python/urllib3.
python_compile() {
	local -x URLLIB3_NO_OVERRIDE=1
	distutils-r1_python_compile
}

# The complete upstream suite requires a large integration-test stack.
distutils_enable_tests import-check
