# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit java-pkg-2

DESCRIPTION="Unified server for Selenium WebDriver: standalone and Grid (hub/node) execution"
HOMEPAGE="https://www.selenium.dev/ https://github.com/SeleniumHQ/selenium"
SRC_URI="https://github.com/SeleniumHQ/selenium/releases/download/selenium-${PV}/selenium-server-${PV}.jar -> ${P}.jar"
S="${WORKDIR}"

# Selenium's own code is Apache-2.0; the rest covers the shaded third-party
# Java libraries bundled in the fat jar (Netty, Guava, Bouncy Castle, ASM,
# Kryo, ANTLR runtime, protobuf, JeroMQ, reactive-streams, jnacl, ...) and
# the embedded prebuilt Selenium Manager helper binaries, whose own vendored
# Rust crates pull in the CDLA-Permissive-2.0/ISC/Unicode-3.0/ZLIB/BZIP2 set
# (see dev-util/selenium-manager for that same helper packaged standalone).
LICENSE="Apache-2.0 BSD BSD-2 BZIP2 CDLA-Permissive-2.0 ISC MIT MIT-0 MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# java-pkg-2 already sets RDEPEND=JAVA_PKG_E_DEPEND (dev-java/java-config);
# append the runtime's own minimum JRE requirement rather than replacing it.
# On arm64, also pull in dev-util/selenium-manager: the copy of Selenium
# Manager embedded in this jar (org/openqa/selenium/manager/linux/) is a
# static-pie x86-64 ELF binary only (verified with `file` on the extracted
# resource), so it cannot run there. The Java SeleniumManager class checks
# the SE_MANAGER_PATH env var first (confirmed via `strings` on its .class:
# "Selenium Manager set by env 'SE_MANAGER_PATH': %s"), and
# dev-util/selenium-manager already installs an env.d entry exporting
# exactly that variable, so depending on it is enough to make driver
# auto-resolution work on arm64 without hand-writing a config file or
# wrapper script (a refreshed login environment is still needed for that
# env.d entry to actually be visible -- see pkg_postinst).
RDEPEND="${RDEPEND}
	>=virtual/jre-17:*
	arm64? ( dev-util/selenium-manager )
"

src_unpack() {
	# Upstream ships a single runnable jar that is also a self-executing
	# shell/zip polyglot (a "#!/bin/sh ... exec java -jar $0" prelude
	# ahead of the zip data, so it can be run directly as ./file). The
	# default unpack() would still explode it via unzip purely because
	# the filename ends in .jar, so just stage the fetched file as-is.
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_install() {
	java-pkg_newjar "${WORKDIR}/${A}" selenium-server.jar
	java-pkg_dolauncher selenium-server --jar selenium-server.jar
}

pkg_postinst() {
	if use arm64; then
		elog "The Selenium Manager helper embedded in this jar is x86-64 only,"
		elog "so it cannot auto-resolve browser drivers on arm64. This package"
		elog "pulls in dev-util/selenium-manager instead, which exports"
		elog "SE_MANAGER_PATH via env.d to point at its native arm64 binary."
		elog "That env.d entry is only visible in a refreshed login"
		elog "environment: it is not injected into shells already running at"
		elog "install time. Start a new login shell (or manually re-source"
		elog "/etc/profile in each existing one) before running"
		elog "selenium-server, so SE_MANAGER_PATH is actually set."
	fi
}
