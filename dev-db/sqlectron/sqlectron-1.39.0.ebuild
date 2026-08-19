# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils unpacker xdg

DESCRIPTION="Simple and lightweight SQL client with cross database support"
HOMEPAGE="
	https://sqlectron.github.io/
	https://github.com/sqlectron/sqlectron
"
SRC_URI="
	amd64? (
		https://github.com/sqlectron/sqlectron/releases/download/v${PV}/${PN}_${PV}_amd64.deb
			-> ${P}-amd64.deb
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. Unlike the other five amd64-only
# packages in this overlay, sqlectron itself is open source (MIT) and
# Electron does support arm64 Linux in general -- but this -bin ebuild
# tracks upstream's prebuilt GitHub Releases artifact, and upstream only
# publishes an amd64.deb there, no arm64.deb. Real arm64 support would
# require a from-source Electron build, not attempted here.
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

# RDEPEND verified 2026-08-18 with `readelf -d` against the real
# opt/sqlectron/sqlectron ELF extracted from the official .deb, cross-checked
# against the .deb's own control "Depends:". Same Chromium/Electron
# dependency shape as app-editors/cursor and app-editors/kiro in this
# overlay (Electron bundles its own Chromium runtime libs such as
# libEGL/libGLESv2/libvulkan/libffmpeg -- those are not RDEPEND).
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa[gbm(+)]
	net-print/cups
	elibc_glibc? ( sys-libs/glibc )
	sys-apps/dbus
	sys-apps/util-linux
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
	x11-libs/libnotify
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

SQLECTRON_HOME="opt/sqlectron"

src_prepare() {
	default

	pushd "${SQLECTRON_HOME}/locales" >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die
}

src_install() {
	dodir /opt/sqlectron
	cp -ar "${SQLECTRON_HOME}/." "${D}/opt/sqlectron/" || die

	fperms 4711 /opt/sqlectron/chrome-sandbox
	pax-mark m "${ED}/opt/sqlectron/sqlectron"
	dosym ../sqlectron/sqlectron /opt/bin/sqlectron

	sed -e "s|^Exec=/.*/sqlectron|Exec=sqlectron|" \
		usr/share/applications/sqlectron.desktop >"${T}/sqlectron.desktop" || die
	domenu "${T}/sqlectron.desktop"

	local size
	for size in 16 32 48 64 128 256; do
		newicon -s "${size}" \
			"usr/share/icons/hicolor/${size}x${size}/apps/sqlectron.png" sqlectron.png
	done
}

pkg_postinst() {
	xdg_pkg_postinst
}
