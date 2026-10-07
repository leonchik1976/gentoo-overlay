# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk
	sl sr sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop optfeature verify-sig xdg

MY_P="${PN%-bin}-${PV}-linux-glibc2.28"

DESCRIPTION="MySQL development and administration desktop application based on MySQL Shell"
HOMEPAGE="https://www.mysql.com/products/workbench/ https://github.com/mysql/mysql-shell-plugins"
SRC_URI="
	amd64? (
		https://cdn.mysql.com/Downloads/MySQLGUITools/${MY_P}-x86_64.zip
		verify-sig? ( https://cdn.mysql.com/Downloads/MySQLGUITools/${MY_P}-x86_64.zip.asc )
	)
	arm64? (
		https://cdn.mysql.com/Downloads/MySQLGUITools/${MY_P}-aarch64.zip
		verify-sig? ( https://cdn.mysql.com/Downloads/MySQLGUITools/${MY_P}-aarch64.zip.asc )
	)
"
S="${WORKDIR}"

# Workbench, Electron/Chromium and the bundled Shell/Python runtime; see the
# license notices shipped in the release archives, including Chromium credits.
LICENSE="
	GPL-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0
	CC-BY-3.0 CC-BY-4.0 FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 LGPL-2.1+
	MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 PYTHON SGI-B-2.0 SSLeay SunSoft
	Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="strip"

# These are external dependencies of the upstream binaries, including the
# bundled Python extensions. Keep Shell's private libraries in its own RPATH.
RDEPEND="
	!dev-db/mysql-workbench
	app-accessibility/at-spi2-core:2
	app-arch/bzip2:0/1
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libyaml
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	sys-apps/keyutils
	sys-apps/util-linux
	sys-devel/gcc:*
	>=sys-libs/glibc-2.28
	sys-libs/libxcrypt:0/1[compat]
	sys-libs/ncurses:0/6[tinfo]
	virtual/libudev:0/1
	virtual/zlib:0/1
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
	amd64? ( sys-libs/gdbm:0/6[berkdb] )
"
BDEPEND+="
	app-arch/unzip
	verify-sig? ( sec-keys/openpgp-keys-mysql )
"

VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/mysql.asc"

QA_PREBUILT="opt/mysql-workbench/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_install() {
	# Preserve executable modes and the private runtime's relative symlinks.
	dodir /opt/mysql-workbench
	cp -a . "${ED}/opt/mysql-workbench/" || die
	# cp -a also copies Portage's private WORKDIR mode onto the target.
	fperms 0755 /opt/mysql-workbench
	fowners root:root /opt/mysql-workbench/chrome-sandbox
	fperms 4711 /opt/mysql-workbench/chrome-sandbox

	dosym -r /opt/mysql-workbench/mysql-workbench /usr/bin/mysql-workbench
	newicon resources/app/images/app-icon.png mysql-workbench.png
	make_desktop_entry --eapi9 mysql-workbench \
		-n "MySQL Workbench" -i mysql-workbench -c "Development;Database;"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "Secret Service password storage" "app-crypt/libsecret[crypt] virtual/secret-service"
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "local backup setup helper (also needs an administrator-configured Enterprise Backup installation)" \
		">=dev-lang/python-3.10"
}
