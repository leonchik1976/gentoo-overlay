# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# distutils-r1 and pypi support EAPI 8.
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="Checks CloudFormation templates for practices/behaviour that could be improved"
HOMEPAGE="
	https://github.com/aws-cloudformation/cfn-lint/
	https://pypi.org/project/cfn-lint/
"

PATCHES=(
	"${FILESDIR}/${P}-offline-firewall-fixture.patch"
	"${FILESDIR}/${P}-offline-schema-update-test.patch"
)

# Upstream declares LICENSE = "MIT-0" in pyproject.toml; the shipped
# LICENSE file is the plain "MIT No Attribution" text, matching
# Gentoo's MIT-0 license identifier.
LICENSE="MIT-0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# requirements/base.txt in the exact release no longer requires SAM Translator.
RDEPEND+="
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	dev-python/jsonpatch[${PYTHON_USEDEP}]
	>=dev-python/networkx-2.4[${PYTHON_USEDEP}]
	<dev-python/networkx-4[${PYTHON_USEDEP}]
	>=dev-python/sympy-1.14.0[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
BDEPEND+="
	>=dev-python/setuptools-80.10.2[${PYTHON_USEDEP}]
	test? (
		dev-python/pydot[${PYTHON_USEDEP}]
		dev-python/junit-xml[${PYTHON_USEDEP}]
		>=dev-python/jschema-to-python-1.2.3[${PYTHON_USEDEP}]
		>=dev-python/sarif-om-1.0.4[${PYTHON_USEDEP}]
		dev-python/defusedxml[${PYTHON_USEDEP}]
	)
"

# Tests exercise the optional graph, JUnit and SARIF output integrations.
# Their dependencies remain test-only; pytest is enabled below.
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
		# the cfn_lint-1.58.0.tar.gz file listing).
		test/unit/module/maintenance
	)
	# test_api.py::test_graph and template/test_template.py::test_build_graph
	# exercise cfn-lint's optional "graph" extra (dev-python/pydot, declared
	# test? above) and are not deselected -- a normal FEATURES=test build
	# has pydot available and should run them.
	epytest
}
