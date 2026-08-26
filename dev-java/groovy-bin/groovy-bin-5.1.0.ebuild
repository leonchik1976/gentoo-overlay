# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="groovy"

DESCRIPTION="Prebuilt binary distribution of the Apache Groovy programming language"
HOMEPAGE="https://groovy.apache.org/"
SRC_URI="https://dlcdn.apache.org/groovy/${PV}/distribution/apache-groovy-binary-${PV}.zip -> ${P}.zip"

S="${WORKDIR}/${MY_PN}-${PV}"

# PARTIAL LICENSE AUDIT: only the 8 bundled third-party dependencies
# that have a corresponding file in licenses/ were checked (see
# LICENSE= below); other bundled lib/*.jar dependencies (ant,
# jackson-*, jline-*, jna, snakeyaml, ...) were not individually
# verified against their own upstream projects.
#
# Architecture-independent JVM bytecode: the archive contains no
# native (.so/.dll/.dylib) files, verified by inspecting the
# extracted distribution.
#
# Groovy itself (LICENSE at the archive root) is Apache-2.0. The
# archive's own licenses/ directory documents 8 bundled third-party
# dependencies under their own licenses, read directly rather than
# inferred from library names: antlr4, asm, jsr223, and xstream are
# each BSD-3-clause ("Redistribution and use ... provided that the
# following [3] conditions are met"); hamcrest is BSD-3-clause
# equivalent text under its own "BSD License" heading; junit4 is
# EPL-1.0; junit5 is EPL-2.0; jsr166y is a public-domain dedication
# (the classic Doug Lea/JSR-166 "Dedicator"/"Certifier" text). Other
# bundled lib/*.jar dependencies (ant, jackson-*, jline-*, jna,
# snakeyaml, ...) do not have a corresponding file in licenses/ and
# were not individually verified against their own upstream projects.
LICENSE="Apache-2.0 BSD EPL-1.0 EPL-2.0 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="|| ( virtual/jdk:25 virtual/jdk:21 virtual/jdk:17 virtual/jdk:11 )"
BDEPEND="app-arch/unzip"

QA_PRESTRIPPED="usr/bin/.*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	dodir "${dest}"
	cp -r bin conf lib licenses LICENSE NOTICE "${ddest}"/ || die

	local script
	for script in grape groovy groovyc groovyConsole groovydoc groovysh java2groovy; do
		dosym -r "${dest}/bin/${script}" "/usr/bin/${script}"
	done

	dodoc NOTICE
}
