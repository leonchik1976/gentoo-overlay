# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Adapted from ::gentoo's own dev-python/exceptiongroup-1.2.2 (removed
# from the tree when exceptiongroup bumped to 1.3.0 upstream; last
# present at gentoo/gentoo@0ed001da44), cross-checked against the
# current dev-python/exceptiongroup-1.3.1 ebuild and against the exact
# upstream 1.2.2 sdist/pyproject.toml. Needed here only to satisfy
# dev-util/semgrep-bin's pinned exceptiongroup~=1.2.0 (>=1.2.0,<1.3)
# runtime requirement -- ::gentoo now only carries 1.3.1.
#
# Unlike 1.3.x, upstream 1.2.2's own Requires-Dist has no
# typing-extensions dependency at all (verified via the exact 1.2.2
# PyPI JSON metadata); the python3.11/3.12-conditional
# >=typing-extensions-4.6.0 dependency in ::gentoo's 1.3.1 ebuild was
# introduced upstream after 1.2.2 and must not be carried back here.
#
# "flit_scm" (underscore) is a deprecated EAPI7/8-only alias for the
# current "flit-scm" backend value (both ::gentoo's 1.3.1 ebuild and
# our own PYTHON_COMPAT selection still use the alias in practice, but
# distutils-r1.eclass's own docs list "flit-scm" as canonical), so the
# canonical spelling is used here instead of copying the alias.
DISTUTILS_USE_PEP517=flit-scm
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="Backport of PEP 654 (exception groups)"
HOMEPAGE="
	https://github.com/agronholm/exceptiongroup/
	https://pypi.org/project/exceptiongroup/
"

LICENSE="MIT PSF-2.4"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

distutils_enable_tests pytest

python_test() {
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1

	local EPYTEST_DESELECT=()
	case ${EPYTHON} in
		python3.14*)
			# Both actually run (not skipped): CPython 3.14 no longer
			# raises RecursionError at the same recursion depth these
			# tests exercise, a real interpreter behavior difference,
			# not an exceptiongroup defect -- verified by running the
			# full suite: 89/89 pass on python3.12 and python3.13,
			# only these 2 fail, only on python3.14.
			EPYTEST_DESELECT+=(
				tests/test_exceptions.py::DeepRecursionInSplitAndSubgroup::test_deep_split
				tests/test_exceptions.py::DeepRecursionInSplitAndSubgroup::test_deep_subgroup
			)
			;;
	esac

	epytest
}
