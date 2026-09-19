# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PV="${PV}"

DESCRIPTION="ClickHouse server: a fast open-source column-oriented database"
HOMEPAGE="https://clickhouse.com/ https://github.com/ClickHouse/ClickHouse"
SRC_URI="
	amd64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-server-${MY_PV}-amd64.tgz
			-> ${P}-amd64.tgz
	)
	arm64? (
		https://github.com/ClickHouse/ClickHouse/releases/download/v${MY_PV}-lts/clickhouse-server-${MY_PV}-arm64.tgz
			-> ${P}-arm64.tgz
	)
"
S="${WORKDIR}/clickhouse-server-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/clickhouse
	acct-user/clickhouse
"
RDEPEND="
	${ACCT_DEPEND}
	~dev-db/clickhouse-common-static-bin-${PV}
"

src_install() {
	local link
	for link in clickhouse-server clickhouse-keeper clickhouse-keeper-client clickhouse-keeper-converter; do
		dosym -r /usr/bin/clickhouse "/usr/bin/${link}"
	done

	insinto /etc/clickhouse-server
	doins etc/clickhouse-server/config.xml etc/clickhouse-server/users.xml
	insinto /etc/clickhouse-keeper
	doins etc/clickhouse-keeper/keeper_config.xml

	systemd_dounit "${FILESDIR}"/clickhouse-server.service
	systemd_newunit lib/systemd/system/clickhouse-keeper.service clickhouse-keeper.service

	dodoc usr/share/doc/clickhouse-server/{README.md,CHANGELOG.md,AUTHORS}

	keepdir /var/lib/clickhouse /var/log/clickhouse-server
	fowners -R clickhouse:clickhouse /var/lib/clickhouse /var/log/clickhouse-server

	# clickhouse-keeper.service (an unmodified upstream unit, unlike
	# clickhouse-server.service) runs as User=clickhouse and its
	# shipped keeper_config.xml points <log>/<errorlog> at
	# /var/log/clickhouse-keeper, but nothing else creates or owns
	# that directory -- confirmed by an actual failed start:
	# "filesystem error: in create_directories: Permission denied
	# [\"/var/log/clickhouse-keeper\"]". Its coordination data path
	# (/var/lib/clickhouse/coordination/...) needs no separate keepdir
	# since it nests under /var/lib/clickhouse above.
	keepdir /var/log/clickhouse-keeper
	fowners -R clickhouse:clickhouse /var/log/clickhouse-keeper
}
