# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Format messages and post them to Microsoft Teams webhooks"
HOMEPAGE="
	https://github.com/rveachkc/pymsteams/
	https://pypi.org/project/pymsteams/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/requests-2.20.0[${PYTHON_USEDEP}]
"
BDEPEND+="
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"
# Deprecated in ::gentoo, but pymsteams imports httpx directly;
# httpx2 is not a drop-in provider for the httpx module.
BDEPEND+="
	test? (
		>=dev-python/httpx-0.28.1[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}/${P}-python-3.14-test.patch"
)

distutils_enable_tests pytest

# These exercise an external service rather than useful offline unit behavior.
EPYTEST_DESELECT=(
	# Requires the user-specific MS_TEAMS_WEBHOOK environment variable.
	tests/test_webhook.py::test_env_webhook_url
	# Contact external httpstat.us endpoints.
	tests/test_webhook.py::test_http_500
	tests/test_webhook.py::test_http_403
	# Sends its oversized payload to MS_TEAMS_WEBHOOK.
	tests/test_webhook.py::test_message_size
)

pkg_postinst() {
	optfeature "asynchronous Microsoft Teams webhook API" \
		">=dev-python/httpx-0.28.1"
}
