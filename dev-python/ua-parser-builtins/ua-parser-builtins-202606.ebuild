# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Precompiled rules for the Python User Agent Parser"
HOMEPAGE="
	https://github.com/ua-parser/uap-python/
	https://pypi.org/project/ua-parser-builtins/
"
SRC_URI="$(pypi_wheel_url --unpack)"
S=${WORKDIR}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"

distutils_enable_tests unittest

src_prepare() {
	default

	cp REVISION ua_parser_builtins/REVISION || die
}

python_compile() {
	python_domodule \
		"${WORKDIR}"/ua_parser_builtins \
		"${WORKDIR}"/ua_parser_builtins-*.dist-info
}

python_install() {
	distutils-r1_python_install
	python_optimize
}

python_test() {
	"${EPYTHON}" - <<-EOF || die
		import compileall
		import pathlib

		root = pathlib.Path("${BUILD_DIR}/install$(python_get_sitedir)")
		package = root / "ua_parser_builtins"
		assert compileall.compile_dir(package, quiet=1)
		assert (package / "py.typed").is_file()
		revision = package / "REVISION"
		assert revision.read_text().strip()
	EOF
}
