# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature

MY_PN="mcp-client-for-ollama"

DESCRIPTION="MCP client for Ollama and OpenAI-compatible providers"
HOMEPAGE="
	https://github.com/jonigl/mcp-client-for-ollama
	https://pypi.org/project/mcp-client-for-ollama/
	https://pypi.org/project/ollmcp/
"
SRC_URI="
	https://github.com/jonigl/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_PN}-${PV}.gh.tar.gz
"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	<dev-python/any-llm-sdk-1.22.0[ollama,${PYTHON_USEDEP}]
	>=dev-python/any-llm-sdk-1.21.0[ollama,${PYTHON_USEDEP}]
	<dev-python/mcp-1.29[${PYTHON_USEDEP}]
	>=dev-python/mcp-1.25[${PYTHON_USEDEP}]
	<dev-python/prompt-toolkit-3.1[${PYTHON_USEDEP}]
	>=dev-python/prompt-toolkit-3.0.52[${PYTHON_USEDEP}]
	<dev-python/rich-14.3[${PYTHON_USEDEP}]
	>=dev-python/rich-14.2.0[${PYTHON_USEDEP}]
	<dev-python/typer-0.27[${PYTHON_USEDEP}]
	>=dev-python/typer-0.26.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/pytest-9.1.0[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
EPYTEST_IGNORE=(
	# Network-facing update notification check against PyPI.
	tests/test_version.py
)

distutils_enable_tests pytest

python_test() {
	local -x TERM=xterm
	epytest --import-mode=importlib
}

pkg_postinst() {
	optfeature "local Ollama service" sci-ml/ollama
	optfeature "Python Ollama provider support for any-llm-sdk" dev-python/ollama-python
	optfeature "OpenAI-compatible provider support for any-llm-sdk" dev-python/openai
}
