# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TS_BINDINGS=( python )

DISTUTILS_OPTIONAL=1
inherit tree-sitter-grammar distutils-r1

DESCRIPTION="XML grammar for Tree-sitter"
HOMEPAGE="https://github.com/tree-sitter-grammars/tree-sitter-xml"
SRC_URI="https://github.com/tree-sitter-grammars/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+=" python? ( >=dev-python/setuptools-77[${PYTHON_USEDEP}] )"

PATCHES=(
	"${FILESDIR}"/${P}-make.patch
	"${FILESDIR}/${P}-license-metadata.patch"
)

src_test() {
	tree-sitter-grammar_src_test

	use python && distutils-r1_src_test
}

python_test() {
	epytest bindings/python/tests
}
