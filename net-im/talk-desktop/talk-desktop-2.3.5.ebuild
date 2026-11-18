# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# chromium-2 and xdg support EAPI 8.
EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop python-any-r1 xdg
inherit talk-desktop-npm-deps-2.3.5

DESCRIPTION="Nextcloud Talk Desktop client built from source with bundled Electron"
HOMEPAGE="https://github.com/nextcloud/talk-desktop"
ELECTRON_VERSION=44.10.2
SRC_URI="
	https://github.com/nextcloud/talk-desktop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-arm64.zip
	https://dev.gentoo.org/~nowa/talk-icon-rounded.svg
"
talk_desktop_npm_src_uri

# Electron bundles a bunch of things
LICENSE="
	AGPL-3+ 0BSD ISC ZLIB MIT BSD BSD-2 BSD-4 AFL-2.1 Apache-2.0 Ms-PL GPL-2 GPL-3 LGPL-2.1 APSL-2
	unRAR OFL-1.1 CC-BY-SA-3.0 MPL-2.0 android public-domain all-rights-reserved
"
SLOT="0"
KEYWORDS="-* ~arm64"
REQUIRED_USE="elibc_glibc"

RESTRICT="bindist mirror strip"

BDEPEND+="
	${PYTHON_DEPS}
	app-arch/unzip
	>=net-libs/nodejs-24.0.0[npm]
"

RDEPEND="
	!net-im/talk-desktop-bin
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/pango
"

# Forge bundles the application with the upstream prebuilt Electron runtime.
QA_PREBUILT="
	opt/nextcloud-talk-desktop/nextcloud-talk
	opt/nextcloud-talk-desktop/chrome-sandbox
	opt/nextcloud-talk-desktop/chrome_crashpad_handler
	opt/nextcloud-talk-desktop/*.so*
"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack "${P}.tar.gz"
}

src_prepare() {
	default
	"${PYTHON}" "${FILESDIR}/talk-desktop-offline.py" "${DISTDIR}" || die
}

src_configure() {
	chromium_suid_sandbox_check_kernel_config
}

src_compile() {
	export npm_config_cache="${T}/npm-cache"
	export npm_config_offline=true npm_config_audit=false npm_config_fund=false
	npm run build:linux -- --arch=arm64 || die
}

src_install() {
	cd "out/Nextcloud Talk-linux-arm64" || die
	(
		cd locales || die
		chromium_remove_language_paks
	) || die "Failed to prune Electron locale packs"

	newicon -s scalable "${DISTDIR}/talk-icon-rounded.svg" nextcloud-talk.svg

	make_desktop_entry --eapi9 \
		'/opt/bin/nextcloud-talk' \
		-d 'nextcloud-talk' \
		-n 'Nextcloud Talk' \
		-i 'nextcloud-talk' \
		-c 'Chat;Network;Office;'

	local DESTDIR="/opt/nextcloud-talk-desktop"

	exeinto "${DESTDIR}"
	doexe chrome-sandbox chrome_crashpad_handler *.so*
	newexe 'Nextcloud Talk' nextcloud-talk

	insinto "${DESTDIR}"
	doins *.pak *.bin *.json *.dat version
	insopts -m0755
	doins -r locales resources

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fperms 4755 "${DESTDIR}"/chrome-sandbox

	dosym ../nextcloud-talk-desktop/nextcloud-talk /opt/bin/nextcloud-talk
	dodoc LICENSE LICENSES.chromium.html
}
