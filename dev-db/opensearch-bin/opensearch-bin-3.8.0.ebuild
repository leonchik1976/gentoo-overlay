# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN="opensearch"

DESCRIPTION="Distributed search and analytics engine (server + security plugin only)"
HOMEPAGE="https://opensearch.org/ https://github.com/opensearch-project/OpenSearch"
SRC_URI="
	amd64? (
		https://artifacts.opensearch.org/releases/bundle/opensearch/${PV}/${MY_PN}-${PV}-linux-x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://artifacts.opensearch.org/releases/bundle/opensearch/${PV}/${MY_PN}-${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/${MY_PN}-${PV}"

# PARTIAL LICENSE AUDIT: distinct licenses were identified from
# NOTICE.txt's own section headers/text (see LICENSE= below) across
# its 132 sections, but not every one of the 132 sections or every
# individual lib/*.jar was cross-checked against that file's claims.
# Not a complete audit of every bundled component.
#
# Verified against this exact release's own top-level LICENSE.txt
# (Apache-2.0; opensearch-security below is the same upstream project
# under the same license -- confirmed via its jar's own
# Module-Origin: github.com/opensearch-project/security.git).
#
# Deliberate "minimal, not insecure" scope decision: of the upstream
# "bundle" tarball's 26 plugins/, only opensearch-security is
# installed. Every other plugin (opensearch-ml, opensearch-sql,
# opensearch-alerting, ...) is a genuinely optional feature add-on
# and is left out, per "package the server only". Security is not
# treated as an optional feature: without opensearch-security,
# OpenSearch's REST API has *no* authentication or authorization at
# all, which is a materially different (and silently worse) security
# model than the product upstream actually ships -- upstream bundles
# and enables this plugin by default specifically to prevent that.
#
# This package does NOT run the plugin's install_demo_configuration.sh
# (it would embed upstream's well-known, publicly-documented demo
# certificates and the default admin/admin-style credentials into
# every install of this package, which is its own insecure-default
# trap and is explicitly called out against for production use in
# upstream's own docs). Instead: network.host is pinned to loopback
# in the shipped config (see src_install), and the security plugin's
# own requirement for configured TLS certificates (see
# opensearch.service) means the server fails closed -- it will not
# start at all -- until an administrator has actually configured
# them, rather than starting up in some silently-open or
# silently-demo-secured state. (OPENSEARCH_INITIAL_ADMIN_PASSWORD
# plays no part in this: see opensearch.service for why.)
#
# NOTICE.txt (shipped at this exact release's archive root, 7446
# lines across 132 per-component sections) documents the bundled
# third-party dependencies actually present in the lib/ and
# opensearch-security/ trees this ebuild installs, read directly.
# The large majority are Apache-2.0 (its own repeated "Apache
# License" text is the dominant pattern throughout the file).
# Individually identified elsewhere in the same file: asm and the
# Lucene automaton/stopword-list components are each BSD-3-clause
# (their own "BSD license"/"3-clause BSD" text); Bouncy Castle, joni,
# and jcodings are each MIT ("MIT License" explicitly named for each
# in their own sections); Jakarta annotations are EPL-2.0 (its own
# "# Eclipse Public License - v 2.0" section); HdrHistogram is
# dual-licensed CC0-1.0/BSD-2 (the same public-domain dedication
# already verified for dev-db/keycloak-bin), CC0-1.0 chosen here as
# the more specific of the two. JZlib's section notes its early 0.0.x
# releases were LGPL but the version actually bundled here "switched
# over to a BSD-style license", so no LGPL entry is added for it.
LICENSE="Apache-2.0 BSD CC0-1.0 EPL-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

ACCT_DEPEND="
	acct-group/opensearch
	acct-user/opensearch
"
RDEPEND="
	${ACCT_DEPEND}
	dev-java/java-config
	|| ( virtual/jdk:25 virtual/jdk:21 )
"

QA_PRESTRIPPED="opt/${PN}-${SLOT}/.*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	# Use the system JDK (verified: bin/opensearch-env honors
	# OPENSEARCH_JAVA_HOME/JAVA_HOME before falling back to a
	# bundled runtime) instead of the ~200MB bundled jdk/.
	rm -r jdk || die

	sed -i \
		-e '/^#path.data:/a path.data: /var/lib/opensearch' \
		-e '/^#path.logs:/a path.logs: /var/log/opensearch' \
		-e '/^#network.host:/a network.host: _local_' \
		config/opensearch.yml || die

	insinto /etc/opensearch
	doins -r config/.

	dodir "${dest}" "${dest}"/plugins
	cp -r agent bin lib modules LICENSE.txt NOTICE.txt "${ddest}"/ || die
	cp -r plugins/opensearch-security "${ddest}"/plugins/ || die
	dosym -r /etc/opensearch "${dest}"/config
	dosym -r /var/lib/opensearch "${dest}"/data
	dosym -r /var/log/opensearch "${dest}"/logs

	dodoc README.md

	systemd_newunit "${FILESDIR}"/opensearch.service opensearch.service

	keepdir /var/lib/opensearch /var/log/opensearch
	fowners -R opensearch:opensearch /var/lib/opensearch /var/log/opensearch

	# opensearch.keystore is deliberately NOT created here.
	# opensearch-keystore create embeds fresh random cryptographic
	# material on every single invocation -- confirmed directly: two
	# independent runs of this exact release's own opensearch-keystore
	# produced two files with different MD5 sums, not identical ones.
	# Running it at build time would therefore bake ONE such randomly-
	# generated instance into this ebuild's reproducible package
	# image, and every future rebuild of this exact package (a
	# version or revision bump, a --newuse re-emerge, anything that
	# re-runs src_install) would generate yet another different one
	# and merge it over whatever is live -- either silently destroying
	# an administrator's real keystore contents, or, at best, forcing
	# Portage's CONFIG_PROTECT to treat the new file as a conflicting
	# edit on every single rebuild (since old and new content never
	# match), permanently accumulating ._cfg0000_* files that need
	# manual review each time regardless of whether anything
	# meaningful actually changed. Mutable, per-install state like
	# this does not belong in the reproducible build image for either
	# reason. It is instead initialized in pkg_postinst, on the real
	# filesystem, once per actual install (see below). /etc/opensearch
	# itself stays
	# non-writable for the service user either way (root:opensearch,
	# 0750, no group-write bit) -- confirmed by an actual real start
	# against a directory in exactly this state, with a keystore
	# already present: OpenSearch read it with no
	# AccessDeniedException and proceeded straight to its normal
	# fail-closed "No SSL configuration found" exit.
	fowners root:opensearch /etc/opensearch
	fperms 0750 /etc/opensearch
}

pkg_postinst() {
	local keystore="${EROOT}/etc/opensearch/opensearch.keystore"
	local opensearch_bin="${EROOT}/opt/${PN}-${SLOT}/bin/opensearch-keystore"

	# An existing keystore -- this install's own, or an
	# administrator's -- is left completely alone: not upgraded, not
	# rechowned, not rechmoded. It may be password-protected, which
	# opensearch-keystore's own commands handle interactively (a
	# password prompt), something pkg_postinst cannot do safely
	# unattended during an emerge; and even for an unpassworded
	# keystore, this ebuild has no business silently changing
	# ownership/mode an administrator may have deliberately set to
	# something other than this package's own default. See below for
	# how a future OpenSearch version bump must handle keystore format
	# migration instead of doing it here.
	if [[ -e ${keystore} ]]; then
		return
	fi

	# Resolve a JDK from this package's own RDEPEND constraint
	# (virtual/jdk:25 or :21) rather than java-config -O, which
	# reflects whatever JVM is currently eselect'd system-wide and may
	# not be one OpenSearch actually supports (the same class of bug
	# already found and fixed for dev-db/cassandra-bin: a host with a
	# newer default JDK installed for unrelated packages silently
	# breaking a program that needs a specific, older-pinned one).
	local vm
	vm=$(depend-java-query --get-vm 'virtual/jdk:25 virtual/jdk:21') \
		|| die "Unable to resolve a JDK satisfying virtual/jdk:25 or virtual/jdk:21"
	local jhome
	jhome=$(java-config --select-vm="${vm}" --jre-home) \
		|| die "Unable to determine JAVA_HOME for ${vm}"

	# Created here, on the live filesystem, rather than in src_install
	# (see there for why).
	OPENSEARCH_PATH_CONF="${EROOT}/etc/opensearch" OPENSEARCH_JAVA_HOME="${jhome}" \
		"${opensearch_bin}" create \
		|| die "opensearch-keystore create failed"

	# root:opensearch, 0640 -- read-only to the opensearch user this
	# package's unit runs as. Applied ONLY to a keystore this ebuild
	# itself just created (an administrator's own keystore is never
	# touched, per above): an actual real start (both arm64 and
	# amd64) confirmed OpenSearch never needs to write to an
	# already-existing keystore, only to create one that's missing --
	# so the running daemon needs read-only access at most, and only
	# root can change contents later (e.g. via "opensearch-keystore
	# add"). Daemon write access is not granted merely because it's
	# convenient.
	chown root:opensearch "${keystore}" || die
	chmod 0640 "${keystore}" || die

	einfo "Created ${keystore}."
	einfo "Configure TLS certificates in ${EROOT}/etc/opensearch/opensearch.yml before starting;"
	einfo "see the opensearch.service unit's own comments for where to start."
}

# Keystore format across a future version bump: OpenSearch has, at
# points in its Elasticsearch lineage, changed the on-disk keystore
# format between releases, with "opensearch-keystore upgrade"
# provided as the migration path. This ebuild deliberately does NOT
# run that automatically (see pkg_postinst above): an existing
# keystore may be password-protected, and "upgrade" against one needs
# that password entered interactively -- there is no safe way to
# automate that inside an unattended emerge, and this overlay has
# only ever verified "upgrade" as a no-op against an UNPASSWORDED
# keystore, not against an actual format change or a
# password-protected one. Before bumping this package to a newer
# OpenSearch release:
#   1. Check that release's own upstream changelog/release notes for
#      any keystore format change.
#   2. If none, no action needed beyond the version bump itself.
#   3. If there is one, this must become an explicit, interactive,
#      documented administrator procedure (run "opensearch-keystore
#      upgrade" by hand, supplying the keystore password if one is
#      set, before starting the upgraded service) -- not silent
#      pkg_postinst code, for the reasons above.
