# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit webapp

DESCRIPTION="Complete web-based frontend for RRDtool"
HOMEPAGE="https://www.cacti.net/ https://github.com/Cacti/cacti"
SRC_URI="https://github.com/Cacti/cacti/archive/refs/tags/release/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-release-${PV}"

LICENSE="BSD CC-BY-4.0 GPL-2 GPL-2+ LGPL-2.1+ MIT OFL-1.1"
KEYWORDS="~amd64 ~arm64"
IUSE="doc"

RDEPEND="${RDEPEND}
	>=dev-lang/php-8.1[cli,filter,gd,gmp,intl,ldap,mysql,pcntl,pdo,phar,posix,session,simplexml,sockets,sqlite,ssl,unicode,xml,zlib]
	net-analyzer/net-snmp
	net-analyzer/rrdtool[graph]
	virtual/cron
"

need_httpd

src_compile() { :; }

src_install() {
	webapp_src_preinst

	dodoc CHANGELOG README.md
	use doc && dodoc -r docs

	rm -r .github docs tests || die
	rm -f .gitignore .mdlrc .mdl_style.rb CLAUDE.md phpunit.xml || die
	cp include/config.php{.dist,} || die

	dodir "${MY_HTDOCSDIR}"
	cp -R . "${ED}${MY_HTDOCSDIR}" || die

	webapp_serverowned -R \
		"${MY_HTDOCSDIR}"/cache \
		"${MY_HTDOCSDIR}"/log \
		"${MY_HTDOCSDIR}"/rra

	webapp_serverowned -R \
		"${MY_HTDOCSDIR}"/resource/script_queries \
		"${MY_HTDOCSDIR}"/resource/script_server \
		"${MY_HTDOCSDIR}"/resource/snmp_queries \
		"${MY_HTDOCSDIR}"/scripts
	webapp_serverowned \
		"${MY_HTDOCSDIR}"/include/config.php \
		"${MY_HTDOCSDIR}"/include/vendor/csrf/csrf-secret.php

	webapp_configfile "${MY_HTDOCSDIR}"/include/config.php
	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt

	webapp_src_install
}
