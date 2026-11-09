# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 and python-single-r1 support EAPI 8, not EAPI 9.
EAPI=8

DISTUTILS_USE_PEP517=poetry
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 pypi

DESCRIPTION="Lightweight package to seamlessly call OpenAI, Azure, Cohere, Anthropic, etc."
HOMEPAGE="
	https://github.com/BerriAI/litellm
	https://pypi.org/project/litellm/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The PyPI source distribution omits the upstream test suite; the remaining
# test_*.py files are integration examples requiring external services.
RESTRICT="test"

RDEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		>=dev-python/aiohttp-3.10[${PYTHON_USEDEP}]
		dev-python/click[${PYTHON_USEDEP}]
		>=dev-python/fastuuid-0.13.0[${PYTHON_USEDEP}]
		>=dev-python/httpx-0.23.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-6.8.0[${PYTHON_USEDEP}]
		>=dev-python/jinja2-3.1.2[${PYTHON_USEDEP}]
		<dev-python/jinja2-4[${PYTHON_USEDEP}]
		>=dev-python/jsonschema-4.23.0[${PYTHON_USEDEP}]
		<dev-python/jsonschema-5[${PYTHON_USEDEP}]
		>=dev-python/openai-2.8.0[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.5.0[${PYTHON_USEDEP}]
		<dev-python/pydantic-3[${PYTHON_USEDEP}]
		>=dev-python/python-dotenv-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/tiktoken-0.7.0[${PYTHON_USEDEP}]
		sci-ml/tokenizers[${PYTHON_USEDEP}]
	')
"
BDEPEND="${BDEPEND}
	$(python_gen_cond_dep '
		dev-python/wheel[${PYTHON_USEDEP}]
	')
"
