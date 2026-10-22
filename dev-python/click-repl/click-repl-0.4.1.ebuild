# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 currently supports EAPI 8 only.
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Interactive REPL for Click applications"
HOMEPAGE="https://github.com/click-contrib/click-repl"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=dev-python/click-7[${PYTHON_USEDEP}]
	<dev-python/click-9[${PYTHON_USEDEP}]
	>=dev-python/prompt-toolkit-3.0.36[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.7.0[${PYTHON_USEDEP}]
"

# Smoke coverage for the runtime used by PostHog; its integration tests
# additionally exercise the Celery instrumentation with an in-memory broker.
IUSE="test"
RESTRICT="!test? ( test )"
BDEPEND+=" test? ( ${RDEPEND} )"

python_test() {
	"${EPYTHON}" -c "import click_repl" || die "Runtime import failed"
}
