# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Official Python client library for Kubernetes"
HOMEPAGE="
	https://github.com/kubernetes-client/python/
	https://pypi.org/project/kubernetes/
"

SRC_URI="https://github.com/kubernetes-client/python/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/python-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=dev-python/aiohttp-3.13.5[${PYTHON_USEDEP}]
	dev-python/aiohttp-retry[${PYTHON_USEDEP}]
	>=dev-python/certifi-2026.7.22[${PYTHON_USEDEP}]
	>=dev-python/durationpy-0.11[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.8.2[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.13.5[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.16.0[${PYTHON_USEDEP}]
	<dev-python/urllib3-3[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/requests-oauthlib[${PYTHON_USEDEP}]
	>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.8.0[${PYTHON_USEDEP}]
	>=dev-python/websocket-client-0.43.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	kubernetes/e2e_test
	kubernetes/aio/e2e_test
	# Both dynamic test modules import the omitted e2e_test.base module,
	# obtain live-cluster configuration, and exercise cluster resources.
	kubernetes/dynamic/test_client.py
	kubernetes/dynamic/test_discovery.py
	kubernetes/aio/dynamic/client_test.py
	kubernetes/aio/dynamic/discovery_test.py
)

python_test() {
	# The transport tests start loopback servers; ignore host proxy settings.
	local -x http_proxy= https_proxy= all_proxy= HTTP_PROXY= HTTPS_PROXY= ALL_PROXY=
	local -x no_proxy="localhost,127.0.0.1,::1" NO_PROXY="localhost,127.0.0.1,::1"

	local -a EPYTEST_DESELECT=()

	# These tests mock select.select(), but the implementation uses
	# select.poll() when available.  They fail under Python 3.14 without
	# exercising the websocket framing code they intend to test.
	if [[ ${EPYTHON} == python3.14 ]]; then
		EPYTEST_DESELECT=(
			kubernetes/stream/ws_client_test.py::WSClientProtocolTest::test_update_ignores_close_signal_v4
			kubernetes/stream/ws_client_test.py::WSClientProtocolTest::test_update_receives_close_v5
		)
	fi

	epytest
}
