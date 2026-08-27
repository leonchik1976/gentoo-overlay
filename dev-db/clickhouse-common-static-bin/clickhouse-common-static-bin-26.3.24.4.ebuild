# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

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

# PARTIAL LICENSE AUDIT: only ClickHouse's own top-level LICENSE was
# checked. The bundled contrib/ third-party C++ libraries statically
# linked into the binary (see below) were explicitly NOT audited --
# this is disclosed as a gap, not a completed check.
#
# Verified against usr/share/doc/clickhouse-common-static/LICENSE in
# this exact release's official binary archive.
#
# usr/bin/clickhouse is a single, large (~700MB unstripped) static
# C++ binary statically linking numerous third-party libraries from
# ClickHouse's own upstream contrib/ tree (Poco, re2, zstd, Arrow,
# ICU, LLVM, and many more). Unlike this overlay's JVM-based binary
# packages, this artifact embeds no separate per-dependency license
# text extractable from the distributed archive -- confirmed by
# `strings` on the binary finding no embedded license/copyright
# blocks, and the archive ships no THIRD-PARTY-LICENSES-style
# document. A full enumeration would require checking each contrib/
# library against ClickHouse's own upstream source tree (network
# access, not performed here) rather than this exact shipped
# artifact, so it is NOT attempted and is disclosed as a remaining
# gap rather than guessed at from library names.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
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
