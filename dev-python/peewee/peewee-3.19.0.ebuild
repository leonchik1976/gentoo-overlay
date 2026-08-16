# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Adapted from ::gentoo's own dev-python/peewee-3.19.0 (removed from the
# tree when peewee bumped to 4.x upstream; last present at
# gentoo/gentoo@8292096e7c). 3.19.0 is upstream's latest 3.x release
# (verified via PyPI release history), and is needed here only to
# satisfy dev-util/semgrep-bin's pinned peewee~=3.14 (>=3.14,<4)
# runtime requirement -- ::gentoo now only carries the 4.x series.
#
# PYTHON_COMPAT: unlike boltons/wcmatch, python3_12/3_13/3_14 support
# here is not just an assumption -- ::gentoo's own last 3.19.0 ebuild
# already declared PYTHON_COMPAT=( python3_{11..14} ) (python3_11 only
# dropped here as historical/EOL in this tree's eclass), so this
# matches actual prior Gentoo packaging/testing, not an untested guess.
#
# native-extensions/cython: dev-python/cython is kept UNCONDITIONAL in
# BDEPEND, not gated behind native-extensions?, even though ::gentoo's
# current peewee-4.3.0 ebuild does gate it and setup.py's own NO_SQLITE
# path (set below when native-extensions is disabled) discards
# ext_modules before any actual compilation is attempted. Both builds
# (native-extensions on and off) were only ever exercised on a system
# that already had Cython installed, so that specific "Cython genuinely
# absent, native-extensions off" combination was never actually proven
# to work: setup.py's top-level "from Cython.Build import cythonize"
# still runs unconditionally at module-import time regardless of
# NO_SQLITE, and relies on an except-ImportError fallback path that
# expects pre-generated playhouse/_sqlite_{ext,udf}.c files -- which
# this sdist does not ship (only .pyx). Rather than trust that untested
# fallback, Cython stays a hard BDEPEND here.
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )
PYTHON_REQ_USE="sqlite"

inherit distutils-r1

DESCRIPTION="Small Python ORM"
HOMEPAGE="
	https://github.com/coleifer/peewee/
	https://pypi.org/project/peewee/
"
SRC_URI="
	https://github.com/coleifer/peewee/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="examples +native-extensions test"
RESTRICT="!test? ( test )"

DEPEND="
	native-extensions? ( dev-db/sqlite:3= )
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	test? (
		dev-db/postgresql
		dev-python/psycopg:0[${PYTHON_USEDEP}]
		sys-libs/timezone-data
	)
"

distutils_enable_sphinx docs \
	dev-python/sphinx-rtd-theme

src_prepare() {
	default

	# disable test failing on postgres 16
	sed -e 's/test_timeout/_&/' -i tests/sqliteq.py || die
}

src_compile() {
	if ! use native-extensions; then
		local -x NO_SQLITE=1
	fi

	distutils-r1_src_compile
}

src_test() {
	initdb -D "${T}"/pgsql || die
	pg_ctl -w -D "${T}"/pgsql start -o "-h '' -k '${T}'" || die
	createdb -h "${T}" peewee_test || die
	psql -h "${T}" peewee_test -c 'create extension hstore;' || die

	local -x PEEWEE_PSQL_HOST="${T}"
	distutils-r1_src_test

	pg_ctl -w -D "${T}"/pgsql stop || die
}

python_test() {
	"${EPYTHON}" runtests.py -v 2 || die "tests failed under ${EPYTHON}"
}

python_install_all() {
	use examples && DOCS=( examples/ )
	distutils-r1_python_install_all
}
