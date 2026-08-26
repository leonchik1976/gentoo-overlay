# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN=neo4j-community

DESCRIPTION="Graph database (Community Edition)"
HOMEPAGE="https://neo4j.com/"
SRC_URI="https://dist.neo4j.org/${MY_PN}-${PV}-unix.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

# PARTIAL LICENSE AUDIT: based on ThirdPartyLicenses.txt's own
# section headers (see LICENSE= below) plus the core/APOC split
# documented here; individual lib/*.jar files were not independently
# cross-checked against that file's claims or their own upstream
# projects. Not a complete audit of every bundled component.
#
# Verified against this exact release's own LICENSE.txt (core, GPL-3)
# and labs/LICENSE (bundled APOC procedures, Apache-2.0). The
# optional products/neo4j-graph-data-science-*.jar add-on is
# deliberately NOT installed by this ebuild: unlike the rest of this
# "Community" tarball, most of its classes live under the com.neo4j.*
# namespace and gate functionality behind Neo4j, Inc.'s proprietary
# license-key mechanism (see com/neo4j/gds/licensing/ in that jar),
# i.e. it is Enterprise code with an unlicensed fallback mode, not
# GPL-3 Community code. products/neo4j-genai-plugin-*.jar is pure
# org.neo4j.* and is kept.
# ThirdPartyLicenses.txt (shipped at this exact release's archive
# root, 2492 lines) additionally documents these licenses across the
# 235 bundled lib/*.jar dependencies -- confirmed by grepping its own
# section headers, not inferred from library names:
# Apache Software License Version 2.0; BSD License; BSD License
# 2-clause; BSD - Scala License; Common Development and Distribution
# License Version 1.1 (CDDL-1.1); Eclipse Distribution License v1.0
# (a BSD-3-clause-equivalent Eclipse redistribution license, mapped
# to Gentoo's generic BSD entry since ::gentoo has no separate EDL
# identifier); Eclipse Public License v1.0 and v2.0; The GNU General
# Public License Version 2 with the Classpath Exception (used by
# javax.annotation-api and similar JDK-derived API stub jars, not
# Neo4j's own GPL-3 core); Mozilla Public License Version 2.0; The
# MIT License.
LICENSE="Apache-2.0 BSD BSD-2 CDDL-1.1 EPL-1.0 EPL-2.0 GPL-2-with-classpath-exception GPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/neo4j
	acct-user/neo4j
"
RDEPEND="
	${ACCT_DEPEND}
	|| ( virtual/jre:25 virtual/jre:21 )
"

RESTRICT="strip"
QA_PREBUILT="opt/${PN}-${SLOT}/lib/*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	insinto /etc/neo4j
	doins -r conf/.

	dodir "${dest}" "${dest}"/products
	cp -r bin certificates import labs lib licenses plugins web \
		"${ddest}"/ || die
	cp products/neo4j-genai-plugin-*.jar "${ddest}"/products/ || die
	dosym -r /etc/neo4j "${dest}"/conf

	dosym -r /var/lib/neo4j/data "${dest}"/data
	dosym -r /var/log/neo4j "${dest}"/logs
	dosym -r /var/lib/neo4j/run "${dest}"/run

	dodoc README.txt UPGRADE.txt ThirdPartyLicenses.txt

	systemd_newunit "${FILESDIR}"/neo4j.service neo4j.service

	keepdir /var/lib/neo4j/data /var/lib/neo4j/run /var/log/neo4j
	fowners -R neo4j:neo4j /var/lib/neo4j /var/log/neo4j
}
