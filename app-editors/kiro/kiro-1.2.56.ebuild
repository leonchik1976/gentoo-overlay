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
	arm64? (
		https://prod.download.desktop.kiro.dev/releases/stable/linux-arm64/signed/${PV}/deb/kiro-ide-${PV}-stable-linux-arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

# Kiro is proprietary AWS Content; upstream terms do not grant mirroring rights.
# Proprietary application terms and bundled Chromium/Electron notices.
LICENSE="all-rights-reserved Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 FFT2D FTL"
LICENSE+=" IJG ISC LGPL-2 LGPL-2.1 MIT MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unlicense ZLIB"
SLOT="0"
# Exact release artifacts are available for both architectures.
KEYWORDS="~amd64 ~arm64"
IUSE="kerberos"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

# Dependencies audited against both Debian control files and shipped ELF objects.
# amd64 libmsalruntime.so needs GLIBC_2.34; arm64 payload needs GLIBC_2.28.
RDEPEND="
	|| (
		sys-apps/systemd
		sys-apps/systemd-utils
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret[crypt]
	app-misc/ca-certificates
	amd64? (
		dev-libs/openssl:0/3
		net-libs/webkit-gtk:4.1
		net-libs/libsoup:3.0
		sys-apps/util-linux
	)
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa[opengl]
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	amd64? ( >=sys-libs/glibc-2.34 )
	arm64? ( >=sys-libs/glibc-2.28 )
	sys-libs/libcap
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
		# As of 1.1.14, upstream packages node_modules inside node_modules.asar
		# with only native-binary modules (including kerberos) unpacked
		# alongside it under node_modules.asar.unpacked/ -- verified by
		# extracting the .deb; the plain node_modules/kerberos/ path used by
		# earlier releases no longer exists.
		rm -r "${KIRO_HOME}/resources/app/node_modules.asar.unpacked/kerberos" || die
	fi

	dodir /opt/kiro
	cp -ar "${KIRO_HOME}/." "${D}/opt/kiro/" || die

	fperms 4711 /opt/kiro/chrome-sandbox
	pax-mark m "${ED}/opt/kiro/kiro"
	dosym ../kiro/bin/kiro /opt/bin/kiro

	sed -e "s|^Exec=/.*/kiro|Exec=kiro|" \
		-e "s|^Icon=.*|Icon=kiro|" \
		-e "s|^Categories=.*|Categories=TextEditor;Development;IDE;|" \
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
	# New in 1.1: the agent host's TerminalSandboxEngine (out/vs/platform/
	# agentHost/node/agentHostMain.js) checks for and uses bwrap/socat to
	# sandbox agent-run terminal commands, logging a warning and continuing
	# unsandboxed if either is missing -- confirmed by extracting the .deb
	# and grepping the built agent-host code.
	optfeature "sandboxed agent terminal execution" "sys-apps/bubblewrap net-misc/socat"
}
