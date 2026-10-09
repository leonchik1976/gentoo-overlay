# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Send usage data from your Python code to PostHog"
HOMEPAGE="
	https://github.com/PostHog/posthog-python
	https://pypi.org/project/posthog/
"
SRC_URI="https://github.com/PostHog/posthog-python/archive/refs/tags/posthog-v${PV}.tar.gz -> ${P}.gh.tar.gz"

S="${WORKDIR}/posthog-python-posthog-v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="${RDEPEND}
	>=dev-python/backoff-1.10.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.5.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.7[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.2.0[${PYTHON_USEDEP}]
"
DEPEND="${DEPEND} ${RDEPEND}"
BDEPEND="${BDEPEND}
	>=dev-python/setuptools-83.0.0[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
		dev-python/cachetools[${PYTHON_USEDEP}]
		>=dev-python/django-5.2.15[${PYTHON_USEDEP}]
		<dev-python/django-6[${PYTHON_USEDEP}]
		>=dev-python/djangorestframework-3.15[${PYTHON_USEDEP}]
		<dev-python/djangorestframework-4[${PYTHON_USEDEP}]
		>=dev-python/flask-2.2[${PYTHON_USEDEP}]
		>=dev-python/freezegun-1.5.1[${PYTHON_USEDEP}]
		>=dev-python/httpx2-2.13.1[${PYTHON_USEDEP}]
		>=dev-python/jsonschema-4.0[${PYTHON_USEDEP}]
		>=dev-python/mcp-1.28.1[${PYTHON_USEDEP}]
		<dev-python/mcp-2[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-exporter-otlp-proto-http-1.20.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-sdk-1.20.0[${PYTHON_USEDEP}]
		>=dev-python/parameterized-0.8.1[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-bdd-8.1.0[${PYTHON_USEDEP}]
		>=dev-python/python-dateutil-2.9.0_p0[${PYTHON_USEDEP}]
		dev-python/starlette[${PYTHON_USEDEP}]
		>=dev-python/zstandard-0.23.0[${PYTHON_USEDEP}]
	)
"

EPYTEST_DESELECT=(
	"posthog/test/test_consumer.py::TestConsumer::test_message_only_error_logs_include_posthog_prefix"
	"posthog/test/test_consumer.py::TestConsumer::test_request"
	"posthog/test/test_consumer.py::TestConsumer::test_upload"
	"posthog/test/test_exception_capture.py::test_excepthook"
	"posthog/test/test_feature_flags.py::TestLocalEvaluation::test_load_feature_flags_wrong_key"
	"posthog/test/test_request.py::TestRequests::test_should_not_timeout"
	"posthog/test/test_request.py::TestRequests::test_should_timeout"
	"posthog/test/test_request.py::TestRequests::test_valid_request"
)

# The independent fastmcp distribution is unavailable for arm64 in ::gentoo.
# Both optional FastMCP integration modules require it at collection time.
# The official MCP SDK tests remain enabled; its FastMCP is a separate API.
EPYTEST_IGNORE=(
	posthog/test/ai/
	posthog/test/mcp/test_fastmcp_v2.py
	posthog/test/mcp/test_fastmcp_v4.py
)

EPYTEST_PLUGINS=( pytest-asyncio pytest-bdd )
: "${EPYTEST_TIMEOUT:=30}"
distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}/posthog-7.64.0-setup-license.patch"
	"${FILESDIR}/${P}-httpx2.patch"
)

python_test() {
	# Local HTTP-server tests must bypass Portage's distfile-fetch proxy.
	local -x no_proxy="localhost,127.0.0.1,::1" NO_PROXY="localhost,127.0.0.1,::1"
	epytest
	# This transport test needs none of the optional AI SDK integrations.
	local EPYTEST_IGNORE=()
	epytest posthog/test/ai/test_evaluations_transport.py
}
