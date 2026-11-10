# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit java-pkg-2

MY_PN="sonar-scanner-cli"
MY_P="${MY_PN}-${PV}"
SCANNER_HOME="/usr/share/sonar-scanner"

DESCRIPTION="Command-line scanner for SonarQube and SonarQube Cloud"
HOMEPAGE="
	https://github.com/SonarSource/sonar-scanner-cli
	https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/sonarscanner/
"
SRC_URI="
	https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${MY_P}.zip
		-> ${P}.zip
"
S="${WORKDIR}/sonar-scanner-${PV}"

LICENSE="
	LGPL-3
	Apache-2.0 BSD MIT
	|| ( EPL-1.0 LGPL-2.1 )
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND+="
	>=virtual/jre-21:*
"
BDEPEND+="
	app-arch/unzip
"

src_install() {
	java-pkg_jarinto "${SCANNER_HOME}/lib"
	java-pkg_dojar "lib/${MY_P}.jar"

	exeinto "${SCANNER_HOME}/bin"
	newexe bin/sonar-scanner sonar-scanner

	newbin "${FILESDIR}/sonar-scanner" sonar-scanner
	newbin bin/sonar-scanner-debug sonar-scanner-debug

	insinto /etc/sonar-scanner
	doins conf/sonar-scanner.properties

	dodir "${SCANNER_HOME}/conf"
	dosym -r /etc/sonar-scanner/sonar-scanner.properties \
		"${SCANNER_HOME}/conf/sonar-scanner.properties"
}
