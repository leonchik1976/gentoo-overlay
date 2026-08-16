# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Adapted from ::gentoo's own dev-python/jsonschema-4.24.0 and
# dev-python/jsonschema-4.26.0 (::gentoo carries both, but nothing in
# between), cross-checked against the exact upstream 4.25.1 sdist and
# PyPI Requires-Dist. Needed here only to satisfy
# dev-util/semgrep-bin's pinned jsonschema~=4.25.1 (>=4.25.1,<4.26)
# runtime requirement -- neither ::gentoo version is in that range.
#
# rpds-py floor: upstream 4.25.1's own Requires-Dist declares
# "rpds-py>=0.7.1", matching 4.24.0's ebuild, NOT 4.26.0's bumped
# ">=0.25.0" -- that bump happened upstream after 4.25.1, so 4.24.0's
# floor is the correct one here.
#
# jsonpath-ng test dependency: 4.25.1's own
# jsonschema/tests/test_exceptions.py already does a hard top-level
# "import jsonpath_ng" (verified directly in the 4.25.1 sdist), same
# as 4.26.0, so the test BDEPEND that 4.26.0 added is carried over
# here too even though 4.24.0's ebuild predates it and omits it.
DISTUTILS_USE_PEP517=hatchling
PYPI_VERIFY_REPO=https://github.com/python-jsonschema/jsonschema
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="An implementation of JSON-Schema validation for Python"
HOMEPAGE="
	https://pypi.org/project/jsonschema/
	https://github.com/python-jsonschema/jsonschema/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/attrs-22.2.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-specifications-2023.03.6[${PYTHON_USEDEP}]
	>=dev-python/referencing-0.28.4[${PYTHON_USEDEP}]
	>=dev-python/rpds-py-0.7.1[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
	test? (
		dev-python/jsonpath-ng[${PYTHON_USEDEP}]
		!!dev-python/shiboken6
	)
"

# formatter deps
RDEPEND+="
	dev-python/fqdn[${PYTHON_USEDEP}]
	dev-python/idna[${PYTHON_USEDEP}]
	dev-python/isoduration[${PYTHON_USEDEP}]
	>=dev-python/jsonpointer-1.13[${PYTHON_USEDEP}]
	dev-python/rfc3339-validator[${PYTHON_USEDEP}]
	dev-python/rfc3986-validator[${PYTHON_USEDEP}]
	dev-python/rfc3987[${PYTHON_USEDEP}]
	dev-python/uri-template[${PYTHON_USEDEP}]
	>=dev-python/webcolors-24.6.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# requires pip, does not make much sense for the users
		jsonschema/tests/test_cli.py::TestCLIIntegration::test_license
		# fragile warning tests
		jsonschema/tests/test_deprecations.py
		# wtf?
		jsonschema/tests/test_jsonschema_test_suite.py::test_suite_bug
	)

	epytest
}
