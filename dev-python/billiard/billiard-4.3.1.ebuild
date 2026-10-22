# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 currently supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Multiprocessing pool extensions for Celery"
HOMEPAGE="https://github.com/celery/billiard"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Smoke coverage for the runtime used by PostHog; its integration tests
# additionally exercise the Celery instrumentation with an in-memory broker.
IUSE="test"
RESTRICT="!test? ( test )"

python_test() {
	"${EPYTHON}" -c "import billiard.pool" || die "Runtime import failed"
}
