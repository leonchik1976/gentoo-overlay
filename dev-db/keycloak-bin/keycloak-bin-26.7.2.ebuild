# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN="keycloak"

DESCRIPTION="Open source identity and access management (Quarkus distribution)"
HOMEPAGE="https://www.keycloak.org/"
SRC_URI="https://github.com/keycloak/keycloak/releases/download/${PV}/${MY_PN}-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

# PARTIAL LICENSE AUDIT: of 471 bundled lib/*.jar dependencies, only
# the 208 that embed their own META-INF/LICENSE were checked (see
# LICENSE= below); the remaining 263 were not individually verified
# against their own upstream projects. Not a complete audit of every
# bundled component.
#
# Keycloak itself (LICENSE.txt at the archive root) is Apache-2.0.
# No native (.so/.dll/.dylib) files are present in the distribution.
#
# This is a large binary bundle (471 lib/*.jar dependencies); it
# ships no aggregated third-party notice, so its 208 jars that embed
# their own META-INF/LICENSE were scanned directly (the other 263 do
# not embed one and were not individually verified against their own
# upstream projects). Distinct licenses actually found: the large
# majority are Apache-2.0 (including all Jackson-* modules, glassfish
# ClassMate, jose4j, etc.); slf4j-api/jcl-over-slf4j (QOS.ch's own
# bundled MIT text, matching the same finding already verified for
# dev-db/cassandra-bin); the JAXB/Jakarta EE reference-implementation
# family (jaxb-core, jaxb-runtime, txw2, jakarta.xml.soap-api,
# jakarta.activation-api, istack-commons-runtime, stax-ex,
# angus-activation, saaj-impl) under Oracle's own BSD-3-clause text
# (one of them, saaj-impl, additionally self-declares
# "SPDX-License-Identifier: BSD-3-Clause", confirming the mapping to
# Gentoo's generic BSD entry rather than a separate EDL identifier,
# same as already found in dev-db/neo4j-bin); the PostgreSQL JDBC
# driver under PostgreSQL's own license (Gentoo's POSTGRESQL entry);
# HdrHistogram under its own dual CC0-1.0/BSD dedication (CC0-1.0
# used here as the more specific of the two); jna under
# "SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1" (Apache-2.0 side
# chosen, as already found in cassandra-bin); a handful of Eclipse
# components explicitly under EPL-2.0.
LICENSE="Apache-2.0 BSD CC0-1.0 EPL-2.0 MIT POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# "db" is a build-time-only choice baked in by kc.sh build (see
# src_install): it selects which JDBC driver/dialect Quarkus compiles
# in, not a runtime-togglable feature, so it fits Gentoo's
# alternative-implementation USE-flag model rather than PG0001's
# optional-runtime-dependency model. All six values are backed by a
# JDBC driver already bundled in lib/ (verified directly: postgres,
# mysql, mariadb, and mssql each have both their driver jar and a
# matching io.quarkus.quarkus-jdbc-*-deployment jar present;
# dev-file/dev-mem need no driver). oracle and tidb are deliberately
# not offered: Oracle's own redistribution terms keep its JDBC driver
# out of this archive entirely (only the quarkus-jdbc-oracle
# deployment jar is present, no ojdbc driver), and tidb was not
# independently verified to work with a bundled driver.
#
# Decision: no default is set, deliberately, even though that means
# `emerge` refuses to even start building this package until a db-*
# flag is chosen (see the RequiredUseDefaults note below). Keycloak's
# own kc.sh build calls the dev-file default "deprecated" for the
# production profile (confirmed by an actual build), and dev-file/
# dev-mem are H2-backed and not durable across restarts in any
# meaningful production sense -- an admin who ends up on one of those
# by inaction, rather than by deliberate choice, has a real
# data-durability problem, not just a cosmetic warning. This mirrors
# the same choice already made for dev-db/opensearch-bin (fail
# closed on missing TLS config rather than default to an
# insecure/demo state): this overlay consistently prefers a build or
# start that refuses to proceed over one that silently proceeds on a
# vendor-deprecated or unsafe default.
IUSE="db-dev-file db-dev-mem db-mariadb db-mssql db-mysql db-postgres"
REQUIRED_USE="^^ ( db-dev-file db-dev-mem db-mariadb db-mssql db-mysql db-postgres )"
# pkgcheck's RequiredUseDefaults finding for this (every profile's
# default USE state fails REQUIRED_USE, since nothing here defaults
# on) is expected and accepted: it means `emerge` refuses to even
# start building until db-* is set explicitly, which is the point --
# the alternative is exactly the silent Keycloak-deprecated default
# this flag group exists to avoid.

ACCT_DEPEND="
	acct-group/keycloak
	acct-user/keycloak
"
RDEPEND="
	${ACCT_DEPEND}
	|| ( virtual/jdk:21 virtual/jdk:17 )
"
# kc.sh build (see src_install) runs its Quarkus augmentation step at
# package-build time, so a JDK is also needed then.
BDEPEND="|| ( virtual/jdk:21 virtual/jdk:17 )"

RESTRICT="strip"
QA_PRESTRIPPED="opt/${PN}-${SLOT}/.*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	insinto /etc/keycloak
	doins -r conf/.

	dodir "${dest}"
	cp -r bin lib providers themes "${ddest}"/ || die
	dosym -r /etc/keycloak "${dest}"/conf
	dosym -r /var/lib/keycloak "${dest}"/data

	# Keycloak's "start" (production mode) auto-detects config changes
	# and re-runs this same Quarkus augmentation step at every launch
	# if it hasn't been done already, writing its output into its own
	# lib/quarkus/ -- which fails under this package's
	# ProtectSystem=strict unit ("Read-only file system"), confirmed
	# by an actual failed start. Pre-build here instead (dosym -r above
	# makes ${dest}/conf a relative symlink that also resolves inside
	# ${ED}, so kc.sh build reads the real, just-installed
	# keycloak.conf) and use "start --optimized" at runtime, which
	# needs no further writes to the install tree -- confirmed by an
	# actual start against a read-only copy of this exact tree.
	local db_vendor
	if use db-dev-file; then
		db_vendor=dev-file
	elif use db-dev-mem; then
		db_vendor=dev-mem
	elif use db-mariadb; then
		db_vendor=mariadb
	elif use db-mssql; then
		db_vendor=mssql
	elif use db-mysql; then
		db_vendor=mysql
	elif use db-postgres; then
		db_vendor=postgres
	fi
	"${ddest}"/bin/kc.sh build --db="${db_vendor}" || die "kc.sh build failed"

	dodoc README.md LICENSE.txt version.txt

	systemd_newunit "${FILESDIR}"/keycloak.service keycloak.service

	keepdir /var/lib/keycloak /var/log/keycloak
	fowners -R keycloak:keycloak /var/lib/keycloak /var/log/keycloak
	fowners -R root:keycloak /etc/keycloak
	fperms 0750 /etc/keycloak
}
