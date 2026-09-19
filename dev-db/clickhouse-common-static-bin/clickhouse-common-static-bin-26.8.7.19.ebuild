# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PV="${PV}"

DESCRIPTION="Common files and the ClickHouse multi-call binary"
HOMEPAGE="https://clickhouse.com/ https://github.com/ClickHouse/ClickHouse"
SRC_URI="
	amd64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-common-static-${MY_PV}-amd64.tgz
			-> ${P}-amd64.tgz
	)
	arm64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-common-static-${MY_PV}-arm64.tgz
			-> ${P}-arm64.tgz
	)
"
S="${WORKDIR}/clickhouse-common-static-${MY_PV}"

# Verified bundled sources include LZ4, Zstandard, Poco, bzip2, and libuv.
# Other bundled components still need a source-level license audit.
LICENSE="Apache-2.0 BSD-2 BSD Boost-1.0 BZIP2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/clickhouse"

src_install() {
	dodir /usr/bin
	# The clickhouse binary is a large (~200MB) multi-call binary;
	# clickhouse-bin and clickhouse-client-bin symlink their
	# clickhouse-server/clickhouse-client/etc. entry points to it.
	exeinto /usr/bin
	doexe usr/bin/clickhouse

	dodoc usr/share/doc/clickhouse-common-static/{README.md,CHANGELOG.md,AUTHORS}
}
