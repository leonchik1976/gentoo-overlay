# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1

MY_PV=${PV/_beta/b}
MY_P="opentelemetry-python-contrib-${MY_PV}"
OTLP_PV=1.45.1
OTLP_P="opentelemetry-python-${OTLP_PV}"
DESCRIPTION="Web utilities for OpenTelemetry"
HOMEPAGE="https://opentelemetry.io/ https://github.com/open-telemetry/opentelemetry-python-contrib/"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
	test? (
		https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${OTLP_PV}.tar.gz
			-> ${OTLP_P}.gh.tar.gz
	)
"
S="${WORKDIR}/${MY_P}/util/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# Exact release pyproject omits these direct imports; __init__.py imports
# semantic conventions; httplib.py imports instrumentation, API and wrapt.
RDEPEND+="
	>=dev-python/opentelemetry-api-1.12[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-${OTLP_PV}[${PYTHON_USEDEP}]
	>=dev-python/wrapt-1.0.0[${PYTHON_USEDEP}]
	<dev-python/wrapt-3.0.0[${PYTHON_USEDEP}]
"
BDEPEND+="
	test? (
		>=dev-python/asgiref-3[${PYTHON_USEDEP}]
		<dev-python/asgiref-4[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-sdk-${OTLP_PV}[${PYTHON_USEDEP}]
		>=dev-python/requests-2.28[${PYTHON_USEDEP}]
		<dev-python/requests-3[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	cp -a "${BUILD_DIR}"/{install,test} || die
	local -x PATH=${BUILD_DIR}/test/usr/bin:${PATH}

	pushd "${WORKDIR}/${OTLP_P}/tests/opentelemetry-test-utils" >/dev/null || die
	distutils_pep517_install "${BUILD_DIR}/test"
	popd >/dev/null || die

	epytest
}
