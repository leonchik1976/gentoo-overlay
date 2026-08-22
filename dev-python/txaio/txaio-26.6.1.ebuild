# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: bug #967367 - ::gentoo masked >=txaio-25.10 (2025-12-12, upstream's
# shift to "LLM-first coding") then last-rited and removed txaio
# (2026-08-21) in lockstep with dev-python/autobahn, which hard-requires it;
# no CVE or reproducible defect was ever cited. Re-added here at the latest
# upstream release because dev-python/autobahn and dev-util/buildbot need
# it. Re-evaluate upstream's release quality before bumping further.

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Compatibility API between asyncio/Twisted/Trollius"
HOMEPAGE="
	https://github.com/crossbario/txaio/
	https://pypi.org/project/txaio/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

# Upstream base package has no hard runtime deps (pyproject.toml
# [project.dependencies] is empty); the "twisted" extra is pulled in
# unconditionally because dev-python/autobahn and dev-util/buildbot
# (the only consumers in this overlay) always use the Twisted backend.
RDEPEND="
	>=dev-python/zope-interface-5.2.0[${PYTHON_USEDEP}]
	>=dev-python/twisted-22.10.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		${RDEPEND}
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"

python_test() {
	epytest
}
