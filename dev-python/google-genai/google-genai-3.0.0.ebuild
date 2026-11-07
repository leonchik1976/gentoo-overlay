# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Google Gen AI Python SDK"
HOMEPAGE="
	https://github.com/googleapis/python-genai/
	https://pypi.org/project/google-genai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/anyio-4.8.0[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/google-auth-2.56.0[${PYTHON_USEDEP}]
	<dev-python/google-auth-3[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.0.0[${PYTHON_USEDEP}]
	<dev-python/httpx2-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.5[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/requests-2.30.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/tenacity-8.2.3[${PYTHON_USEDEP}]
	<dev-python/tenacity-9.2.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-13.0.0[${PYTHON_USEDEP}]
	<dev-python/websockets-18[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	<dev-python/distro-2[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
"
BDEPEND+="
	>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
	test? (
		dev-python/absl-py[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}/${P}-build-backend.patch"
	"${FILESDIR}/${P}-httpx2-tests.patch"
)

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

python_test() {
	# These unit tests do not require API credentials, replay data or ML extras.
	epytest --mode=replay google/genai/tests/{common,errors,types}
}
