# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# distutils-r1.eclass only supports EAPI 8 as of this writing (see its
# @SUPPORTED_EAPIS header); EAPI 9 is not yet usable here.
#
# ::gentoo carries dev-python/cfn-lint, but only 1.54.0 and newer --
# nothing satisfies app-admin/aws-sam-cli's "cfn-lint>=1.52.0,<1.54"
# requirement. This overlay adds 1.53.3, the newest release still inside
# that window.
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="Checks CloudFormation templates for practices/behaviour that could be improved"
HOMEPAGE="
	https://github.com/aws-cloudformation/cfn-lint/
	https://pypi.org/project/cfn-lint/
"

# Upstream declares LICENSE = "MIT-0" in pyproject.toml; the shipped
# LICENSE file is the plain "MIT No Attribution" text, matching
# Gentoo's MIT-0 license identifier.
LICENSE="MIT-0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Exact 1.53.3 Requires-Dist (base, non-extra), verified against both
# requirements/base.txt in the sdist and the PyPI JSON API's
# info.requires_dist for this exact version:
#   pyyaml>=6.0.3
#   aws-sam-translator>=1.111.0
#   jsonpatch
#   networkx>=2.4,<4
#   sympy>=1.14.0
#   regex
#   typing_extensions
# All are satisfied by current ::gentoo versions; no new transitive
# packages were needed.
RDEPEND="
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	>=dev-python/aws-sam-translator-1.111.0[${PYTHON_USEDEP}]
	dev-python/jsonpatch[${PYTHON_USEDEP}]
	>=dev-python/networkx-2.4[${PYTHON_USEDEP}]
	<dev-python/networkx-4[${PYTHON_USEDEP}]
	>=dev-python/sympy-1.14.0[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/pydot[${PYTHON_USEDEP}]
		dev-python/defusedxml[${PYTHON_USEDEP}]
	)
"

# requirements/dev.txt (not shipped in the sdist, checked directly
# against the v1.53.3 tag on GitHub) additionally lists pydot and
# defusedxml for the test suite; pytest/coverage are pulled in
# automatically by distutils_enable_tests below.
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Upstream's own pytest.ini_options already sets
	# `addopts = ["-m not data"]`, deselecting the slow/large
	# "data"-marked template-corpus tests by default.
	local EPYTEST_IGNORE=(
		# Requires network access to fetch full CloudFormation resource
		# schemas via `cfn-lint -u` before these can even collect.
		test/integration
		# Repo-hygiene tests, not applicable to a packaged sdist: one
		# `git grep`s the source tree for rule-ID/doc consistency (no
		# .git present in ${S}), the other opens
		# scripts/update_specs_from_pricing.py via a hardcoded
		# ../../../../scripts path -- scripts/ is a top-level dev-repo
		# directory the sdist does not ship (verified: not present in
		# the cfn_lint-1.53.3.tar.gz file listing).
		test/unit/module/maintenance
	)
	# test_api.py::test_graph and template/test_template.py::test_build_graph
	# exercise cfn-lint's optional "graph" extra (dev-python/pydot, declared
	# test? above) and are not deselected -- a normal FEATURES=test build
	# has pydot available and should run them.
	epytest
}
