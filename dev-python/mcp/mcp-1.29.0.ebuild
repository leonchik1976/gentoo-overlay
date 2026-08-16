# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# New package: not present in ::gentoo. Direct runtime dependency of
# dev-util/semgrep-bin (mcp==1.29.0, exact pin). Started from ::guru's
# dev-python/mcp-1.28.1 as a structural reference, but every dependency
# below was re-verified against the exact 1.29.0 sdist/wheel metadata,
# not copied from 1.28.1 -- upstream restructured its dependency groups
# between those two releases (see notes below).
DISTUTILS_USE_PEP517=hatchling
PYPI_VERIFY_REPO=https://github.com/modelcontextprotocol/python-sdk
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Model Context Protocol SDK"
HOMEPAGE="
	https://modelcontextprotocol.io/
	https://github.com/modelcontextprotocol/python-sdk
	https://pypi.org/project/mcp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream's exact 1.29.0 Requires-Dist (verified from the released
# sdist/wheel METADATA, not from 1.28.1):
#
#   anyio>=4.5
#   httpx-sse>=0.4
#   httpx<1.0.0,>=0.27.1
#   jsonschema>=4.20.0
#   pydantic-settings>=2.5.2
#   pydantic<3.0.0,>=2.11.0 ; python_version < "3.14"
#   pydantic<3.0.0,>=2.12.0 ; python_version >= "3.14"
#   pyjwt[crypto]>=2.10.1
#   python-multipart>=0.0.9
#   sse-starlette>=1.6.1
#   starlette>=0.27 ; python_version < "3.14"
#   starlette>=0.48.0 ; python_version >= "3.14"
#   typing-extensions>=4.9.0
#   typing-inspection>=0.4.1
#   uvicorn>=0.31.1 ; sys_platform != "emscripten"
#   python-dotenv>=1.0.0 ; extra == "cli"
#   typer>=0.16.0 ; extra == "cli"
#   rich>=13.9.4 ; extra == "rich"
#   websockets>=15.0.1 ; extra == "ws"
#
# python_version-conditional pydantic/starlette bounds are collapsed to
# the single stricter (python3_14) atom below: >=2.12.0 and >=0.48.0
# both also satisfy the looser <3.14 branch, so one atom correctly
# covers every PYTHON_COMPAT target without needing a per-impl split.
#
# The "cli"/"rich"/"ws" extras (python-dotenv, typer, rich, websockets)
# are genuinely optional as of 1.29.0 (unlike 1.28.1, where cli deps
# were unconditional) and semgrep only imports mcp.server.*/mcp.types/
# mcp.shared.* (FastMCP server-side API), never mcp.cli -- verified by
# grepping the semgrep wheel's own imports. Left as optfeature only,
# per PG0001.
#
# pyjwt has no "crypto" USE flag in ::gentoo's dev-python/pyjwt, so
# dev-python/cryptography is declared directly here instead, as
# dev-util/semgrep-bin already does for its own pyjwt[crypto] need.
#
# dev-python/httpx-sse and dev-python/sse-starlette do not exist in
# ::gentoo; both are used from ::guru (httpx-sse-0.4.3,
# sse-starlette-3.4.3/3.4.4), which satisfy mcp's uncapped lower
# bounds with no version conflict, unlike the OpenTelemetry situation.
RDEPEND="
	>=dev-python/anyio-4.5[${PYTHON_USEDEP}]
	>=dev-python/httpx-sse-0.4[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27.1[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.5.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
	>=dev-python/sse-starlette-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.48.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.31.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/dirty-equals-0.9.0[${PYTHON_USEDEP}]
		dev-python/inline-snapshot[${PYTHON_USEDEP}]
		>=dev-python/rich-13.9.4[${PYTHON_USEDEP}]
		>=dev-python/websockets-15.0.1[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( anyio inline-snapshot )
EPYTEST_XDIST=1
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# Fix TOCTOU port assignment issue, still present upstream in 1.29.0
	# https://bugs.gentoo.org/979158
	cat >> tests/conftest.py <<-EOF || die

		def pytest_collection_modifyitems(items):
		    for item in items:
		        if hasattr(item.module, "server_port"):
		            item.add_marker(pytest.mark.xdist_group(name="toctou_fix"))
	EOF
}

python_test() {
	local EPYTEST_IGNORE=(
		# Requires dev-python/pytest-examples which depends on missing Python
		# bindings in dev-util/ruff::gentoo
		tests/test_examples.py
	)
	local EPYTEST_DESELECT=(
		# Runs dev-python/uv and requires network access
		tests/client/test_config.py::test_command_execution
	)

	epytest -m "xdist_group" --collect-only
	epytest --dist=loadgroup
}

pkg_postinst() {
	optfeature "mcp CLI support (python-dotenv, typer)" dev-python/python-dotenv dev-python/typer
	optfeature "colorized log output" dev-python/rich
	optfeature "WebSockets support" dev-python/websockets
}
