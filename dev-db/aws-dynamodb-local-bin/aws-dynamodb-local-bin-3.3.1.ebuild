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
# not let portage's strip pass alter the shipped binaries -- every
# upstream file is kept, unmodified, including the native libraries
# for architectures/platforms other than the one being built for
# (linux-amd64, linux-i386, linux-aarch64, three osx .dylib, two
# win32 .dll -- see DynamoDBLocal_lib/ directly).
RESTRICT="mirror bindist strip"

# All 8 bundled sqlite4java native libraries (3 linux .so, 3 osx
# .dylib, 2 win32 .dll -- everything except the pure-Java
# sqlite4java.jar) are genuinely prebuilt, unmodified upstream
# binaries, not produced by this ebuild's own (nonexistent) build
# step.
QA_PREBUILT="opt/${PN%-bin}/DynamoDBLocal_lib/*sqlite4java-*"

# Only the linux .so files are ELF and therefore even examined by
# Portage's soname/REQUIRES checks at all (the osx/win32 files are
# Mach-O/PE and are simply not parsed as ELF). Of those three, exclude
# by library path/file only the ones that cannot execute on the
# architecture actually being built for -- the active architecture's
# own library file keeps being checked normally against its real
# libc.so.6 requirement, not blanket-excluded.
case ${ARCH} in
	amd64)
		# linux-aarch64 cannot execute on amd64 at all (foreign CPU
		# architecture), so its required libc.so.6 is never
		# satisfiable here -- confirmed unresolved by an actual build
		# on amd64 (server01).
		#
		# linux-i386 is excluded unconditionally too, NOT because it
		# was observed unresolved on that same build: it happened to
		# resolve there, because that particular host has 32-bit/
		# multilib runtime libraries installed, which is host-specific
		# and not guaranteed for every amd64 install this ebuild's
		# ~amd64 keyword covers. Confirmed structurally instead,
		# directly against the actual ::gentoo profile tree
		# (profiles/arch/amd64/no-multilib/make.defaults sets
		# MULTILIB_ABIS="amd64" only, and its use.mask masks
		# abi_x86_32): a host on that profile builds no 32-bit glibc
		# at all, so linux-i386's ELFCLASS32 libc.so.6 requirement
		# (confirmed via this exact library's own recorded NEEDED
		# entry) is unresolvable there regardless of any other
		# package installed. Excluding it unconditionally on amd64
		# avoids depending on which of those two real, differently-
		# configured amd64 hosts happens to be building this package.
		REQUIRES_EXCLUDE="*/libsqlite4java-linux-aarch64.so */libsqlite4java-linux-i386.so"
		;;
	arm64)
		# Neither linux-amd64 nor linux-i386 can execute on arm64 at
		# all (foreign CPU architecture in both cases), so neither's
		# required libc.so.6 is ever satisfiable here -- confirmed
		# unresolved by an actual build on arm64 (this host).
		# linux-aarch64 itself resolves against the real, present
		# system libc and is not excluded.
		REQUIRES_EXCLUDE="*/libsqlite4java-linux-amd64.so */libsqlite4java-linux-i386.so"
		;;
esac

src_install() {
	local dest="/opt/${PN%-bin}"
	local ddest="${ED}/${dest#/}"

	dodir "${dest}"
	cp -r . "${ddest}"/ || die

	newbin "${FILESDIR}"/aws-dynamodb-local aws-dynamodb-local

	dodoc LICENSE.txt README.txt THIRD-PARTY-LICENSES.txt
}
