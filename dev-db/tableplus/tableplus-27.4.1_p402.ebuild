# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Modern, native GUI tool for relational and NoSQL databases"
MY_PV=${PV/_p/-}

HOMEPAGE="https://tableplus.com/"
SRC_URI="
	amd64? (
		https://deb.tableplus.com/debian/26/pool/main/t/tableplus/tableplus_${MY_PV}_amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://deb.tableplus.com/debian/26-arm/pool/main/t/tableplus/tableplus_${MY_PV}_arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

# The package bundles Breakpad and the Snowflake driver. The driver embeds
# OpenSSL 3.5.8 under Apache-2.0. See the installed notice sources for details.
LICENSE="all-rights-reserved Apache-2.0 Boost-1.0 BSD BSD-2 curl MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	elibc_glibc? ( >=sys-libs/glibc-2.35 )
	virtual/zlib
	virtual/krb5
	x11-libs/cairo[glib]
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/pango
	x11-libs/gtksourceview:3.0
"

QA_PREBUILT="opt/tableplus/*"

src_prepare() {
	default

	sed -i \
		-e 's:^Exec=.*:Exec=/opt/tableplus/tableplus %u:' \
		-e 's:^Icon=.*:Icon=tableplus:' \
		opt/tableplus/tableplus.desktop || die
}

src_install() {
	insinto /opt/tableplus
	doins -r opt/tableplus/resource
	doins opt/tableplus/tableplus-crash-reporter.tar.gz
	doins opt/tableplus/libtpsnowflake.so
	exeinto /opt/tableplus
	doexe opt/tableplus/tableplus opt/tableplus/crashpad_handler
	doexe opt/tableplus/tableplus-mcp

	dosym ../../opt/tableplus/tableplus /usr/bin/tableplus

	doicon -s 256 opt/tableplus/resource/image/tableplus.png
	domenu opt/tableplus/tableplus.desktop

	tar -xOf opt/tableplus/tableplus-crash-reporter.tar.gz ./LICENSE.breakpad \
		> "${T}/LICENSE.breakpad" || die
	dodoc "${T}/LICENSE.breakpad"
	dodoc -r "${FILESDIR}/snowflake-driver-notices"
}
