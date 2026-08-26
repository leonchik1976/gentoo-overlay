# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Highly scalable, eventually consistent, distributed NoSQL database"
HOMEPAGE="https://cassandra.apache.org/"
SRC_URI="https://downloads.apache.org/cassandra/${PV}/apache-${PN%-bin}-${PV}-bin.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/apache-cassandra-${PV}"

# PARTIAL LICENSE AUDIT: only Cassandra's own LICENSE.txt and the
# ~20 (of ~85) bundled lib/*.jar dependencies that embed their own
# META-INF/LICENSE were checked (see LICENSE= below); the remaining
# ~65 jars were not individually verified against their own upstream
# projects. Not a complete audit of every bundled component.
#
# Cassandra's own Ant/Maven-based source build resolves ~80 direct
# (and many more transitive) Java dependencies from Maven Central at
# build time via generated POM files (.build/cassandra-deps-template.xml,
# .build/cassandra-build-deps-template.xml processed through the
# "write-poms" Ant target), with no offline/vendored fallback and no
# equivalent set of dev-java/* packages available in ::gentoo. A fully
# offline source build is not practical to maintain here, so this
# package uses Apache's own official prebuilt binary distribution
# instead, which is signed and checksummed by the Cassandra project
# like the source tarball.
# Cassandra itself (LICENSE.txt/NOTICE.txt at the archive root) is
# Apache-2.0. This is a binary bundle of ~85 third-party lib/*.jar
# dependencies, most of which do not embed their own license text in
# this exact archive (no separate licenses/ directory or per-jar
# NOTICE is shipped) -- individually verifying each against its own
# upstream project is impractical here and was not done for all of
# them. Of the ~20 jars that DO embed a META-INF/LICENSE(.txt),
# inspected directly: jcl-over-slf4j/log4j-over-slf4j/slf4j-api are
# MIT (QOS.ch's own bundled license text, not inferred); jna and
# jna-platform embed "SPDX-License-Identifier: Apache-2.0 OR
# LGPL-2.1" (dual-licensed; Apache-2.0 is a compliant choice under
# that OR, so no separate LGPL-2.1 entry is added); every other
# jar with an embedded license text (apache-cassandra itself,
# caffeine, cassandra-driver-core, commons-cli, commons-lang3,
# commons-math3, guava, the jackson-* jars, lucene-*) is Apache-2.0.
# The remaining ~60 undocumented-in-archive jars are not reflected
# below as a remaining, disclosed gap rather than a guess.
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/cassandra
	acct-user/cassandra
"
RDEPEND="
	${ACCT_DEPEND}
	|| ( virtual/jre:17 virtual/jre:11 )
"

RESTRICT="strip"
QA_PREBUILT="opt/${PN}-${SLOT}/lib/*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	# The shipped cassandra.yaml comments out
	# data_file_directories/commitlog_directory/saved_caches_directory/
	# hints_directory entirely (using /var/lib/cassandra/* only as
	# example text), so Cassandra falls back to its own internal
	# default of data/* relative to its install directory -- which is
	# read-only under this ebuild's layout. Confirmed by an actual
	# failed start: "FSWriteError: ... /opt/cassandra-bin-0/data:
	# Read-only file system". Activate the exact paths this ebuild
	# actually keepdir's/owns below instead.
	cp -r conf "${T}"/conf || die
	sed -i \
		-e 's|^# hints_directory: /var/lib/cassandra/hints$|hints_directory: /var/lib/cassandra/hints|' \
		-e 's|^# data_file_directories:$|data_file_directories:|' \
		-e 's|^#     - /var/lib/cassandra/data$|    - /var/lib/cassandra/data|' \
		-e 's|^# commitlog_directory: /var/lib/cassandra/commitlog$|commitlog_directory: /var/lib/cassandra/commitlog|' \
		-e 's|^# saved_caches_directory: /var/lib/cassandra/saved_caches$|saved_caches_directory: /var/lib/cassandra/saved_caches|' \
		"${T}"/conf/cassandra.yaml || die
	insinto /etc/cassandra
	doins -r "${T}"/conf/.

	dodir "${dest}"
	# Configuration moves to /etc/cassandra (a symlink below);
	# everything else (bin/, lib/, tools/, doc/, pylib/) is
	# installed as shipped by upstream.
	cp -r bin lib tools doc pylib "${ddest}"/ || die
	dosym -r /etc/cassandra "${dest}"/conf

	# bin/cassandra.in.sh hardcodes cassandra_storagedir="$CASSANDRA_HOME/data"
	# unconditionally (no environment-variable override exists for
	# it), and this becomes -Dcassandra.storagedir on the JVM command
	# line, which takes precedence over the cassandra.yaml keys
	# uncommented above for at least some of Cassandra's own startup
	# directory creation -- confirmed by an actual failed start that
	# still wrote to /opt/cassandra-bin-0/data/commitlog (read-only)
	# despite commitlog_directory being correctly set in the deployed
	# cassandra.yaml. Point this at the same /var/lib/cassandra tree
	# instead, matching the keepdir layout below (commitlog/data/etc.
	# become direct children of it, exactly as cassandra.yaml already
	# specifies).
	sed -i \
		-e 's|^cassandra_storagedir="\$CASSANDRA_HOME/data"$|cassandra_storagedir="/var/lib/cassandra"|' \
		"${ddest}"/bin/cassandra.in.sh || die

	dodoc CHANGES.txt NEWS.txt
	dodoc -r doc/cql3

	systemd_newunit "${FILESDIR}"/cassandra.service cassandra.service

	keepdir /var/lib/cassandra/data /var/lib/cassandra/commitlog
	keepdir /var/lib/cassandra/saved_caches /var/lib/cassandra/hints
	keepdir /var/log/cassandra
	fowners -R cassandra:cassandra /var/lib/cassandra /var/log/cassandra
}
