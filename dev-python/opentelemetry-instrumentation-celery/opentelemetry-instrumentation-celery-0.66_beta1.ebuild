# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 currently supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="OpenTelemetry instrumentation for Celery"
HOMEPAGE="https://github.com/open-telemetry/opentelemetry-python-contrib"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=dev-python/celery-4[${PYTHON_USEDEP}]
	<dev-python/celery-6[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.12[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-0.66_beta1[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-1.45.1[${PYTHON_USEDEP}]
"

# Smoke coverage for the runtime used by PostHog; its integration tests
# additionally exercise the Celery instrumentation with an in-memory broker.
IUSE="test"
RESTRICT="!test? ( test )"
BDEPEND+=" test? ( ${RDEPEND} )"

python_test() {
	"${EPYTHON}" -c "import opentelemetry.instrumentation.celery" || die "Runtime import failed"
}
