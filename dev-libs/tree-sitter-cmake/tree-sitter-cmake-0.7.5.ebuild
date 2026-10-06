# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TS_BINDINGS=( python )

inherit tree-sitter-grammar python-r1 toolchain-funcs

DESCRIPTION="CMake grammar for tree-sitter"
HOMEPAGE="https://github.com/uyha/tree-sitter-cmake"
SRC_URI="https://github.com/uyha/tree-sitter-cmake/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+=" python? ( >=dev-python/setuptools-77[${PYTHON_USEDEP}] )"

PATCHES=( "${FILESDIR}/${PN}-0.7.4-python-metadata.patch" )

src_test() {
	# The upstream CLI otherwise guesses a non-Gentoo compiler triplet.
	tc-export CC CXX
	tree-sitter-grammar_src_test
}
