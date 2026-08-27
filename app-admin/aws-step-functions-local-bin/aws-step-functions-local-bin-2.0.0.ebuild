# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Downloadable, local version of AWS Step Functions for testing (unsupported)"
HOMEPAGE="https://docs.aws.amazon.com/step-functions/latest/dg/sfn-local.html"
SRC_URI="https://s3.amazonaws.com/stepfunctionslocal/StepFunctionsLocal.zip"

S="${WORKDIR}"

# PARTIAL LICENSE AUDIT: licenses below were read from the archive's
# own third_party_licenses/ summary and per-component files, trusting
# that document's own groupings rather than independently
# re-verifying each named component against its own upstream project.
# Not a complete audit of every bundled component.
#
# AWS Step Functions Local itself is proprietary, governed by the AWS
# Customer Agreement (see licenses/AWS-Customer-Agreement, copied
# verbatim from this exact archive's own LICENSE.txt).
#
# The archive additionally ships an authoritative
# third_party_licenses/"Third Party Licenses.txt" summary plus
# per-component license files for its bundled OSS dependencies, read
# directly rather than inferred from library names. The large
# majority (Apache-HttpComponents-*, AtInject, DaggerRuntime, Gson,
# ion-java, J2EE Servlet, the Jackson-* jars, JakartaCommons-*,
# JaywayJsonPath, Jetty-alpn-api, JMESPathJava, Json-smart, and the
# AWS SDK's own jars) are Apache-2.0, confirmed by the file's own
# "Licensed under the Apache License, Version 2.0" heading covering
# that group. Individually verified separately: Jetty itself is
# dual-licensed EPL-1.0/Apache-2.0 (its own
# LICENSE-eplv10-aslv20.html), Apache-2.0 chosen as the permissive
# side; joda-time is Apache-2.0 (its own LICENSE.txt, despite being
# grouped near the BSD section in the combined summary); Hamcrest and
# ASM are each BSD-3-clause (their own "BSD License" text); Lombok
# and Slf4j are each MIT (their own "Permission is hereby granted,
# free of charge..." text, QOS.ch's for Slf4j matching the same
# finding already verified for dev-db/cassandra-bin).
#
# AWS's own docs mark this tool "unsupported" and recommend it only
# for local testing, never for sensitive data.
#
# The archive is pure JVM bytecode for the tool itself, but is NOT
# entirely free of native code: the bundled Aws-crt-java-1.0.x.jar
# embeds prebuilt libaws-crt-jni shared objects for several
# platforms (linux/x86_64, linux/armv8, osx, windows, ...), inside
# the jar as resources selected at runtime by the JVM -- verified by
# inspecting that jar's contents directly. Both amd64 (x86_64) and
# arm64 (armv8) are covered by this single archive, so no separate
# per-arch SRC_URI is needed.
LICENSE="AWS-Customer-Agreement Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=virtual/jre-17:*"
BDEPEND="app-arch/unzip"

# Redistribution is not permitted under the AWS Customer Agreement:
# fetch only from the official AWS URL above, and do not let Gentoo
# or overlay mirrors cache/redistribute this distfile.
RESTRICT="mirror bindist"

src_install() {
	local dest="/opt/${PN%-bin}"
	local ddest="${ED}/${dest#/}"

	dodir "${dest}"
	cp -r . "${ddest}"/ || die

	newbin "${FILESDIR}"/aws-step-functions-local aws-step-functions-local

	dodoc LICENSE.txt README.txt NOTICE.txt
}
