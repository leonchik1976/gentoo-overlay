# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Modern, native GUI tool for relational and NoSQL databases"
HOMEPAGE="https://tableplus.com/"
SRC_URI="
	amd64? (
		https://deb.tableplus.com/debian/26/pool/main/t/tableplus/tableplus_${PV}_amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://deb.tableplus.com/debian/26-arm/pool/main/t/tableplus/tableplus_${PV}_arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-crypt/libsecret
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	elibc_glibc? ( sys-libs/glibc )
	virtual/krb5
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
"

QA_PREBUILT="opt/tableplus/*"

src_prepare() {
	default

	sed -i \
		-e 's:^Exec=.*:Exec=/opt/tableplus/tableplus:' \
		-e 's:^Icon=.*:Icon=tableplus:' \
		opt/tableplus/tableplus.desktop || die
}

src_install() {
	insinto /opt/tableplus
	doins -r opt/tableplus/resource
	exeinto /opt/tableplus
	doexe opt/tableplus/tableplus opt/tableplus/crashpad_handler

	dosym ../../opt/tableplus/tableplus /usr/bin/tableplus

	doicon -s 256 opt/tableplus/resource/image/tableplus.png
	domenu opt/tableplus/tableplus.desktop
}
