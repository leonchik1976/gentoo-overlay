# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

POSTGRES_COMPAT=( 14 15 16 17 18 )
POSTGRES_USEDEP="server(+)"

inherit postgres-multi toolchain-funcs

DESCRIPTION="Vector similarity search for PostgreSQL"
HOMEPAGE="https://github.com/pgvector/pgvector"
SRC_URI="https://github.com/pgvector/pgvector/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${POSTGRES_REQ_USE}"

RDEPEND="${POSTGRES_DEP}"
DEPEND="${RDEPEND}"

# installcheck requires the extension to be installed in a running server.
RESTRICT="test"

DOCS=( README.md CHANGELOG.md )

pgvector_emake() {
	# Override PGXS's saved compiler/flags and upstream's -march=native.
	# Retain PostgreSQL's aliasing, overflow and feature-test requirements.
	emake CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -fno-strict-aliasing -fwrapv" \
		CPPFLAGS="${CPPFLAGS} -D_GNU_SOURCE" \
		LDFLAGS="${LDFLAGS}" LDFLAGS_SL= OPTFLAGS= "$@"
}

src_compile() {
	postgres-multi_foreach pgvector_emake
}

src_install() {
	postgres-multi_foreach pgvector_emake DESTDIR="${D}" install
	einstalldocs
}

pkg_postinst() {
	elog "Enable pgvector in each database that needs it with:"
	elog "  CREATE EXTENSION vector;"
	elog "After upgrading, update existing extensions in each database with:"
	elog "  ALTER EXTENSION vector UPDATE;"
}
