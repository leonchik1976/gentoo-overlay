# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Downloadable, local version of Amazon DynamoDB for development and testing"
HOMEPAGE="https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html"
SRC_URI="https://d1ni2b6xgvw0s0.cloudfront.net/v2.x/dynamodb_local_latest.tar.gz"

S="${WORKDIR}"

# PARTIAL LICENSE AUDIT: licenses below were read from the archive's
# own THIRD-PARTY-LICENSES.txt, trusting that document's own
# groupings rather than independently re-verifying each named
# component against its own upstream project. Not a complete audit
# of every bundled component.
#
# Verified against this exact archive's own LICENSE.txt: the
# dedicated "Amazon DynamoDB Local License Agreement" (see
# licenses/Amazon-DynamoDB-Local-License-Agreement, copied verbatim),
# NOT the generic AWS Customer Agreement text used by
# app-admin/aws-step-functions-local-bin. This license explicitly
# prohibits distribution, transfer, modification, decompilation, and
# sub-licensing of the Software (clause "Limitations").
#
# Native SQLite libraries were inspected directly: DynamoDBLocal_lib/
# ships real ELF shared objects for both linux-amd64
# (libsqlite4java-linux-amd64.so, x86-64) and linux-arm64
# (libsqlite4java-linux-aarch64.so, ARM aarch64), verified with
# file(1) -- not inferred from AWS's Docker image supporting both
# platforms. `java -jar DynamoDBLocal.jar -version` was run
# successfully on this overlay's native arm64 host using the bundled
# aarch64 .so, confirming it actually loads and works, not just that
# the file is present.
#
# NOTE: AWS does not publish a version-pinned download URL for this
# tool; the URL above is a rolling "latest" pointer that AWS updates
# in place. PV here reflects this exact archive's own reported
# version (`java -jar DynamoDBLocal.jar -version` -> 3.3.1) at
# packaging time. If AWS replaces the file behind this URL, the next
# `pkgdev manifest` run will fail its checksum until this ebuild is
# re-verified and bumped -- this is intentional (fail loudly on
# unexpected content change) rather than a defect.
#
# THIRD-PARTY-LICENSES.txt (shipped at this exact archive's root)
# documents the bundled OSS dependencies, read directly. The large
# majority (annotations, commons-cli, commons-lang, ion-element,
# Amazon ION Java, JakartaCommons-codec, joda-time, Findbugs Jsr305,
# the Kotlin stdlib/reflect jars, log4j and log4j-core,
# partiql-ir-generator-runtime, sqlite4java itself, the
# Apache-HttpComponents-* jars, servlet-api, netty-all and the
# netty-reactive-streams jars, google-guava, jetty, and the
# jackson-* jars) are Apache-2.0, confirmed by the file's continuous
# "Apache License, Version 2.0" text covering that group. Separately
# identified further down the same file: ANTLR is BSD-3-clause
# ("[The 'BSD 3-clause license']", its own heading); the bundled
# codepointat.js/fromcodepoint.js polyfills and Reactive Streams are
# each MIT (their own "Permission is hereby granted, free of
# charge..." text); slf4j is MIT (QOS.ch's own bundled text, matching
# the same finding already verified for dev-db/cassandra-bin). These
# additions describe the OSS dependencies' own licenses only and do
# not relax the Amazon DynamoDB Local License Agreement governing the
# proprietary Software itself (see RESTRICT below).
LICENSE="Amazon-DynamoDB-Local-License-Agreement Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=virtual/jre-17:*"

# Redistribution, transfer, and modification are prohibited by the
# license: fetch only from the official AWS URL above, do not let
# Gentoo or overlay mirrors cache/redistribute this distfile, and do
# not let portage's strip pass alter the shipped binaries (native
# .so files for other Linux architectures, plus macOS/Windows
# artifacts, are intentionally left in place unmodified rather than
# trimmed, consistent with not altering the archive as distributed;
# expect a benign pkgcheck/QA "unresolved soname" notice for the
# non-target-arch libsqlite4java .so files this implies).
RESTRICT="mirror bindist strip"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	dodir "${dest}"
	cp -r . "${ddest}"/ || die

	newbin "${FILESDIR}"/aws-dynamodb-local aws-dynamodb-local

	dodoc LICENSE.txt README.txt THIRD-PARTY-LICENSES.txt
}
