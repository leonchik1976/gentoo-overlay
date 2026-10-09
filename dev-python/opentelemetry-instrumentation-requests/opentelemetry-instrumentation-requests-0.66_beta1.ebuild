# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1

MY_PV=${PV/_beta/b}
MY_P="opentelemetry-python-contrib-${MY_PV}"
OTLP_PV=1.45.1
DESCRIPTION="OpenTelemetry requests instrumentation"
HOMEPAGE="https://opentelemetry.io/ https://github.com/open-telemetry/opentelemetry-python-contrib/"
SRC_URI="https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz -> ${MY_P}.gh.tar.gz"
S="${WORKDIR}/${MY_P}/instrumentation/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RDEPEND+="
	>=dev-python/opentelemetry-api-1.12[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-${OTLP_PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-util-http-${PV}[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0[${PYTHON_USEDEP}]
	<dev-python/requests-3[${PYTHON_USEDEP}]
"
# Upstream tests require mocket, unavailable in the configured repositories,
# and opentelemetry-test-utils staged from the core source tree.
RESTRICT="test"
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
