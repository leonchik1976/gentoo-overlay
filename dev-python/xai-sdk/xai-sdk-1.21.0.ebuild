# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Official Python SDK for the xAI API"
HOMEPAGE="
	https://github.com/xai-org/xai-sdk-python/
	https://pypi.org/project/xai-sdk/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/grpcio-1.72.1[${PYTHON_USEDEP}]
	<dev-python/grpcio-2[${PYTHON_USEDEP}]
	>=dev-python/protobuf-5.29.4[${PYTHON_USEDEP}]
	<dev-python/protobuf-8[${PYTHON_USEDEP}]
	>=dev-python/googleapis-common-protos-1.65.0[${PYTHON_USEDEP}]
	<dev-python/googleapis-common-protos-2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.5.3[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/requests-2.31.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.8.6[${PYTHON_USEDEP}]
	<dev-python/aiohttp-4[${PYTHON_USEDEP}]
	>=dev-python/packaging-25.0[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.36.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-sdk-2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"
BDEPEND+="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/${P}-packaging-version.patch" )

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

python_test() {
	# Local unit tests; mock-server integration tests need unpackaged portpicker.
	epytest tests/{chat,file_content,telemetry}_test.py
}
