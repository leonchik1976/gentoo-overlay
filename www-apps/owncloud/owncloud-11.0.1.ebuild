# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit webapp

DESCRIPTION="Self-hosted file sync and share server"
HOMEPAGE="https://owncloud.com/"
SRC_URI="https://github.com/owncloud/core/releases/download/v${PV}/${PN}-${PV}.tar.bz2"

S="${WORKDIR}/${PN}"

# Verified against this exact release's own COPYING file: still
# AGPL-3, despite an incomplete, in-progress, per-repository
# relicensing effort toward Apache-2.0 that has not been applied to
# this release. apps/files_mediaviewer/ is bundled under GPL-2
# (its own LICENSE file) rather than AGPL-3.
LICENSE="AGPL-3 GPL-2"
KEYWORDS="~amd64 ~arm64"

IUSE="+curl +imagemagick mysql postgres +sqlite"
REQUIRED_USE="|| ( mysql postgres sqlite )"

RDEPEND="
	>=dev-lang/php-8.3[curl?,filter,gd,hash(+),intl,json(+),mysql?,pdo,posix,postgres?,session,simplexml,sqlite?,truetype,xmlreader,xmlwriter,zip]
	<dev-lang/php-8.6
	imagemagick? ( dev-php/pecl-imagick )
	virtual/httpd-php
"

pkg_setup() {
	webapp_pkg_setup
}

src_install() {
	webapp_src_preinst

	insinto "${MY_HTDOCSDIR}"
	doins -r .
	keepdir "${MY_HTDOCSDIR}"/data

	webapp_serverowned -R "${MY_HTDOCSDIR}"/apps
	webapp_serverowned -R "${MY_HTDOCSDIR}"/data
	webapp_serverowned -R "${MY_HTDOCSDIR}"/config
	webapp_configfile "${MY_HTDOCSDIR}"/.htaccess
	webapp_configfile "${MY_HTDOCSDIR}"/.user.ini

	webapp_src_install
}
