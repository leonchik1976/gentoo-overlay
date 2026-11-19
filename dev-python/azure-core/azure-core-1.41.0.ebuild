# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..15} )
inherit distutils-r1 pypi

DESCRIPTION="Core library for Microsoft Azure Python SDKs"
HOMEPAGE="https://pypi.org/project/azure-core/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/requests-2.21.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.6.0[${PYTHON_USEDEP}]
"
BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# The global fixture starts a Flask server. Run the self-contained tests
	# without it; the serialization tests also lack the modeltypes fixture.
	local offline='not async and not trio'
	offline+=' and not test_basic_requests and not test_basic_options_requests'
	offline+=' and not test_request_text and not test_complicated_json'
	offline+=' and not test_request_policies and not test_per_call_policies_old_then_new'
	offline+=' and not test_multipart_tuple_input_multiple_same_name'
	offline+=' and not test_data_and_file_input_same_name'
	epytest --noconftest -k "${offline}" \
		tests/test_{paging,pipeline,rest_http_request,utils}.py
}
