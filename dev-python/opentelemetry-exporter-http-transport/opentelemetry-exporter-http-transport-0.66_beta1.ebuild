# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit pypi distutils-r1
DESCRIPTION="OpenTelemetry HTTP exporter transport implementations"
HOMEPAGE="https://opentelemetry.io/ https://github.com/open-telemetry/opentelemetry-python/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RDEPEND+="
	>=dev-python/opentelemetry-api-1.15[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
"
# Backends are optional runtime imports; the consumer declares its chosen
# requests or urllib3 dependency. Both implementations are always installed.
# Full upstream tests additionally require unpackaged mocket and both backends.
RESTRICT="test"
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
