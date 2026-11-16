# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Use uv's bundled upstream backend without a per-interpreter uv-build wrapper.
DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..15} python3_{14..15}t )
inherit distutils-r1 pypi

DESCRIPTION="Thread-safe asyncio-aware queue for Python"
HOMEPAGE="https://github.com/aio-libs/janus"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+="
	>=dev-python/uv-0.13.8
	<dev-python/uv-0.14
	>=dev-python/gpep517-16[${PYTHON_USEDEP}]
	test? ( dev-python/pytest-asyncio[${PYTHON_USEDEP}] )
"

EPYTEST_PLUGINS=( pytest-asyncio )
EPYTEST_IGNORE=( tests/test_benchmarks.py )
distutils_enable_tests pytest

python_compile() {
	# Keep the backend version bound in sync with upstream pyproject.toml.
	uv build --offline --no-cache --no-python-downloads --no-build-isolation \
		--python "${PYTHON}" --wheel --out-dir "${BUILD_DIR}/wheel" \
		|| die "Wheel build failed"
	distutils_wheel_install "${BUILD_DIR}/install" \
		"${BUILD_DIR}/wheel/${PN}-${PV}-py3-none-any.whl"
}

python_test() {
	# Coverage reporting is a developer workflow, not part of the test result.
	epytest -o addopts=
}
