# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 currently supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Distributed task queue"
HOMEPAGE="https://docs.celeryq.dev/ https://github.com/celery/celery"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=dev-python/billiard-4.2.1[${PYTHON_USEDEP}]
	<dev-python/billiard-5[${PYTHON_USEDEP}]
	>=dev-python/kombu-5.6.0[${PYTHON_USEDEP}]
	>=dev-python/vine-5.1.0[${PYTHON_USEDEP}]
	<dev-python/vine-6[${PYTHON_USEDEP}]
	>=dev-python/click-8.1.2[${PYTHON_USEDEP}]
	<dev-python/click-9[${PYTHON_USEDEP}]
	>=dev-python/click-didyoumean-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/click-repl-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/click-plugins-1.1.1[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.8.2[${PYTHON_USEDEP}]
	dev-python/tzlocal[${PYTHON_USEDEP}]
"

# Smoke coverage for the runtime used by PostHog; its integration tests
# additionally exercise the Celery instrumentation with an in-memory broker.
IUSE="test"
RESTRICT="!test? ( test )"
BDEPEND+=" test? ( ${RDEPEND} )"

python_test() {
	"${EPYTHON}" -c "import celery" || die "Runtime import failed"
}
