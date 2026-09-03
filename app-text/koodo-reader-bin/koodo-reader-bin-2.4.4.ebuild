# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 unpacker xdg

DESCRIPTION="Cross-platform ebook reader with sync and backup capabilities"
HOMEPAGE="https://www.koodoreader.com/ https://github.com/koodo-reader/koodo-reader"
SRC_URI="
	amd64? ( https://github.com/koodo-reader/koodo-reader/releases/download/v${PV}/Koodo-Reader-${PV}-amd64.deb )
	arm64? ( https://github.com/koodo-reader/koodo-reader/releases/download/v${PV}/Koodo-Reader-${PV}-arm64.deb )
"
S="${WORKDIR}"

LICENSE="
	AGPL-3
	0BSD AFL-2.1 APSL-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 BSD-4
	Boost-1.0 CC-BY-3.0 CC-BY-SA-3.0 FFT2D FTL GPL-2 IJG ISC LGPL-2 LGPL-2.1
	MIT MPL-1.1 MPL-2.0 Ms-PL OFL-1.1 SGI-B-2.0 SSLeay SunSoft Unicode-3.0
	Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB all-rights-reserved android libpng
	libtiff openssl public-domain unRAR
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	amd64? ( >=sys-libs/glibc-2.34 )
	arm64? ( >=sys-libs/glibc-2.38 )
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	rm -r "opt/Koodo Reader/resources/assets/macos" || die

	# Use the PATH launcher and remove a duplicate MIME type (bug #815793).
	sed -i \
		-e 's|^Exec=.*|Exec=koodo-reader %U|' \
		-e 's|;application/vnd.amazon.ebook;application/vnd.amazon.ebook;|;application/vnd.amazon.ebook;|' \
		usr/share/applications/koodo-reader.desktop || die

	mv usr/share/doc/koodo-reader usr/share/doc/${PF} || die
	gunzip usr/share/doc/${PF}/changelog.gz || die
}

src_install() {
	insinto /
	doins -r opt usr

	fperms +x \
		"/opt/Koodo Reader/chrome-sandbox" \
		"/opt/Koodo Reader/chrome_crashpad_handler" \
		"/opt/Koodo Reader/koodo-reader"
	fowners root "/opt/Koodo Reader/chrome-sandbox"
	fperms 4711 "/opt/Koodo Reader/chrome-sandbox"

	dosym "../../opt/Koodo Reader/koodo-reader" /usr/bin/koodo-reader
}
