# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PV="${PV}"

DESCRIPTION="Common files and the ClickHouse multi-call binary"
HOMEPAGE="https://clickhouse.com/ https://github.com/ClickHouse/ClickHouse"
SRC_URI="
	amd64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-stable/clickhouse-common-static-${MY_PV}-amd64.tgz
			-> ${P}-amd64.tgz
	)
	arm64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-stable/clickhouse-common-static-${MY_PV}-arm64.tgz
			-> ${P}-arm64.tgz
	)
"
S="${WORKDIR}/clickhouse-common-static-${MY_PV}"

# Bundled license texts audited using this release's system.licenses table.
LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0 BZIP2 CC0-1.0"
LICENSE+=" CDLA-Permissive-2.0 ISC LGPL-2.1 MIT MPL-2.0 OPENLDAP POSTGRESQL Unicode-3.0"
LICENSE+=" UoI-NCSA ZLIB openssl public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="strip"

RDEPEND=">=sys-libs/glibc-2.17"

QA_PREBUILT="usr/bin/clickhouse"

src_install() {
	dodir /usr/bin
	# The clickhouse binary is a large (~200MB) multi-call binary;
	# clickhouse-bin and clickhouse-client-bin symlink their
	# clickhouse-server/clickhouse-client/etc. entry points to it.
	exeinto /usr/bin
	doexe usr/bin/clickhouse

	dodoc usr/share/doc/clickhouse-common-static/{README.md,CHANGELOG.md,AUTHORS,LICENSE}
}
