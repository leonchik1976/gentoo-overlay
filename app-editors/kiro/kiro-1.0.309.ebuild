# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop optfeature pax-utils shell-completion unpacker xdg

DESCRIPTION="AI IDE for spec-driven development, based on Code - OSS"
HOMEPAGE="https://kiro.dev/"
SRC_URI="
	amd64? (
		https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/${PV}/deb/kiro-ide-${PV}-stable-linux-x64.deb
			-> ${P}-amd64.deb
	)
"
S="${WORKDIR}"

# Kiro is proprietary "AWS Content" (https://kiro.dev/license/), licensed
# under the AWS Customer Agreement / AWS Intellectual Property License. That
# page does not itself grant redistribution/mirroring rights, so distfiles
# are not mirrored. It bundles Chromium (BSD) and, for the CLI, Bun (MIT)
# with LGPL-2/LGPL-2.1 components (JavaScriptCore, WebKit, tinycc) that this
# -bin IDE package does not ship.
LICENSE="all-rights-reserved"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. Unlike app-admin/kiro-cli-bin,
# Kiro's desktop IDE download tree only publishes a linux-x64 release
# (prod.download.desktop.kiro.dev/releases/stable/linux-x64/...); no
# linux-arm64 path exists.
KEYWORDS="-* ~amd64"
IUSE="kerberos"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

# RDEPEND verified 2026-08-18 with `readelf -d` against the real
# usr/share/kiro/kiro ELF extracted from the .deb; this is the same
# Chromium/Electron (Code - OSS fork) dependency set already used by
# app-editors/cursor in this overlay, which Kiro's binary matches almost
# 1:1 (Kiro is, like Cursor, a VS Code / Code-OSS fork).
RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
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
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	sys-process/lsof
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
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
	kerberos? ( app-crypt/mit-krb5 )
"

QA_PREBUILT="*"

KIRO_HOME="usr/share/kiro"

src_prepare() {
	default

	pushd "${KIRO_HOME}/locales" >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die
}

src_install() {
	# disable update server
	sed -e "/updateUrl/d" -i "${KIRO_HOME}/resources/app/product.json" || die

	if ! use kerberos; then
		rm -r "${KIRO_HOME}/resources/app/node_modules/kerberos" || die
	fi

	dodir /opt/kiro
	cp -ar "${KIRO_HOME}/." "${D}/opt/kiro/" || die

	fperms 4711 /opt/kiro/chrome-sandbox
	pax-mark m "${ED}/opt/kiro/kiro"
	dosym ../kiro/bin/kiro /opt/bin/kiro

	sed -e "s|^Exec=/.*/kiro|Exec=kiro|" \
		-e "s|^Icon=.*|Icon=kiro|" \
		usr/share/applications/kiro.desktop >"${T}/kiro.desktop" || die
	domenu "${T}/kiro.desktop"

	sed -e "s|^Exec=/.*/kiro|Exec=kiro|" \
		-e "s|^Icon=.*|Icon=kiro|" \
		usr/share/applications/kiro-url-handler.desktop >"${T}/kiro-url-handler.desktop" || die
	domenu "${T}/kiro-url-handler.desktop"

	local size
	for size in 16 24 32 48 64 128 256 512 1024; do
		newicon -s "${size}" usr/share/pixmaps/code-oss.png kiro.png
	done

	insinto /usr/share/mime/packages
	doins usr/share/mime/packages/kiro-workspace.xml

	newbashcomp usr/share/bash-completion/completions/kiro kiro
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "keyring support inside kiro" "virtual/secret-service"
}
