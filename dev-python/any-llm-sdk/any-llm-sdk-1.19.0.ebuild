# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Python SDK providing a unified interface across LLM providers"
HOMEPAGE="
	https://docs.mozilla.ai/any-llm/
	https://github.com/mozilla-ai/any-llm
	https://pypi.org/project/any-llm-sdk/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+ollama bedrock"

RDEPEND="
	>=dev-python/anthropic-0.83.0[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	>=dev-python/openai-1.99.3[${PYTHON_USEDEP}]
	>=dev-python/openresponses-types-2.3.0_p1[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
	bedrock? (
		dev-python/boto3[${PYTHON_USEDEP}]
	)
	ollama? (
		>=dev-python/ollama-python-0.5.1[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	test? (
		>=dev-python/pytest-8[${PYTHON_USEDEP}]
		<dev-python/pytest-10[${PYTHON_USEDEP}]
		>=dev-python/pytest-asyncio-0.26.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-rerunfailures-16.0[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=(
	pytest-asyncio
	pytest-rerunfailures
	pytest-timeout
)
distutils_enable_tests pytest

python_test() {
	epytest tests/unit
}

pkg_postinst() {
	optfeature "Mistral provider support" ">=dev-python/mistralai-2.0.0"
	optfeature "Gemini or Vertex AI provider support" \
		"dev-python/google-genai dev-python/google-cloud-storage"
	optfeature "Hugging Face provider support" dev-python/huggingface-hub
	optfeature "Cohere provider support" dev-python/cohere
	optfeature "Cerebras provider support" ">=dev-python/cerebras-cloud-sdk-1.23.0"
	optfeature "Groq provider support" dev-python/groq
	optfeature "Azure AI provider support" dev-python/azure-ai-inference
	optfeature "any-llm platform telemetry/client support" \
		">=dev-python/any-llm-platform-client-0.3.0 >=dev-python/opentelemetry-exporter-otlp-proto-http-1.30.0 >=dev-python/opentelemetry-sdk-1.30.0"
	optfeature "Together provider support" ">=dev-python/together-1.5.34"
	optfeature "Voyage provider support" dev-python/voyageai
	optfeature "xAI provider support" ">=dev-python/xai-sdk-1.0.1"
	optfeature "LM Studio provider support" ">=dev-python/lmstudio-1.5.0"
	optfeature "Otari provider support" ">=dev-python/otari-0.2.0"
}
