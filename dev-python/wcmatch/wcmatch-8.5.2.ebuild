# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Adapted from ::gentoo's own dev-python/wcmatch-8.5.2 (removed from the
# tree when wcmatch bumped to 9.x upstream; last present at
# gentoo/gentoo@c501b129a6). 8.5.2 is upstream's latest 8.x release
# (verified via PyPI release history), and is needed here only to
# satisfy dev-util/semgrep-bin's pinned wcmatch~=8.3 (>=8.3,<9) runtime
# requirement -- ::gentoo now only carries the 11.x series.
#
# PYTHON_COMPAT: upstream 8.5.2's own classifiers declare Python
# 3.8-3.12 only; ::gentoo's own last 8.5.2 ebuild added python3_13
# itself beyond that declared range. python3_14 here is this overlay's
# own addition, not declared by upstream or ::gentoo for this version.
#
# python3.12 has been actually run: 1322/1324 tests pass. The 2
# failures (TestGlobFilter::test_glob_filter[case31] and
# ::test_glob_split_filter[case31], both pattern="" matched against
# filename="") are NOT a test-environment artifact -- unlike the 4
# HOME-related tilde-test failures fixed by the dedicated $HOME setup
# in python_test() below, globfilter() here is pure in-memory pattern
# matching with no filesystem access, and the identical case still
# exists unchanged in upstream's current (post-11.x) test suite. The
# actual cause was not identified (no older Python was available on
# this system to compare against), and semgrep itself never exercises
# empty-string glob patterns, so these 2 failures are reported here as
# open/unexplained rather than deselected without a confirmed cause.
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )
DISTUTILS_USE_PEP517=hatchling

inherit distutils-r1

DESCRIPTION="Wildcard/glob file name matcher"
HOMEPAGE="
	https://github.com/facelessuser/wcmatch/
	https://pypi.org/project/wcmatch/
"
SRC_URI="
	https://github.com/facelessuser/wcmatch/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/bracex-2.1.1[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		dev-vcs/git
	)
"

distutils_enable_tests pytest

python_test() {
	# TestTilde (tests/test_globmatch.py) globs "~/*" and compares the
	# result against a plain os.listdir() of the real $HOME, so it
	# needs $HOME to actually contain something at test time. The
	# Portage-default sandbox $HOME was found (by testing) to not
	# reliably have that content visible to expanduser('~') by the time
	# python_test runs, causing a spurious "0 == 0" failure -- so a
	# dedicated, definitely-populated $HOME is set up right here,
	# scoped to this phase only, instead of relying on an earlier phase.
	local -x HOME="${T}/home"
	mkdir -p "${HOME}" || die
	: > "${HOME}"/test1.txt || die
	: > "${HOME}"/test2.txt || die

	epytest
}
