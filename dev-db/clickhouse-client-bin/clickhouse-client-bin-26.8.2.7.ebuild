# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV}"

DESCRIPTION="Command-line client and local tools for ClickHouse"
HOMEPAGE="https://clickhouse.com/ https://github.com/ClickHouse/ClickHouse"
SRC_URI="
	amd64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-client-${MY_PV}-amd64.tgz
			-> ${P}-amd64.tgz
	)
	arm64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-client-${MY_PV}-arm64.tgz
			-> ${P}-arm64.tgz
	)
"
S="${WORKDIR}/clickhouse-client-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="~dev-db/clickhouse-common-static-bin-${PV}"

src_install() {
	local link
	for link in clickhouse-client clickhouse-local clickhouse-benchmark \
		clickhouse-compressor clickhouse-format clickhouse-obfuscator; do
		dosym -r /usr/bin/clickhouse "/usr/bin/${link}"
	done

	insinto /etc/clickhouse-client
	doins etc/clickhouse-client/config.xml

	dodoc usr/share/doc/clickhouse-client/{README.md,CHANGELOG.md,AUTHORS}
}
