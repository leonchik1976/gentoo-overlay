# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit readme.gentoo-r1

DESCRIPTION="This is the command-line version of the Steam client for dedicated servers"
HOMEPAGE="https://developer.valvesoftware.com/wiki/SteamCMD"
SRC_URI="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linuxarm64.tar.gz -> ${P}-linux-arm64.tar.gz"
S="${WORKDIR}"

LICENSE="Steam"
SLOT="0"
KEYWORDS="-* ~arm64"
REQUIRED_USE="elibc_glibc"

RDEPEND="
	acct-group/steamcmd
	acct-user/steamcmd
	app-misc/dtach
	app-shells/bash
	sys-libs/glibc
"

RESTRICT="bindist mirror strip"

QA_PREBUILT="
	opt/steamcmd/linuxarm64/crashhandler.so
	opt/steamcmd/linuxarm64/steamcmd
	opt/steamcmd/linuxarm64/steamerrorreporter
"

src_install() {
	diropts -o steamcmd -g steamcmd
	dodir /opt/steamcmd
	keepdir /opt/steamcmd/.steam

	exeopts -o steamcmd -g steamcmd
	exeinto /opt/steamcmd
	doexe steamcmd.sh

	exeinto /opt/steamcmd/linuxarm64
	doexe linuxarm64/{steamcmd,steamerrorreporter,crashhandler.so}
	fowners steamcmd:steamcmd /opt/steamcmd/linuxarm64

	newinitd "${FILESDIR}"/steamcmd.initd-r2 steamcmd
	newconfd "${FILESDIR}"/steamcmd.confd-r2 steamcmd

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
