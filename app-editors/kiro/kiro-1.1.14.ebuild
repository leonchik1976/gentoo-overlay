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

# Kiro is proprietary "AWS Content" (https://kiro.dev/license/), licensed
# under the AWS Customer Agreement / AWS Intellectual Property License. That
# page does not itself grant redistribution/mirroring rights, so distfiles
# are not mirrored. It bundles Chromium (BSD) and, for the CLI, Bun (MIT)
# with LGPL-2/LGPL-2.1 components (JavaScriptCore, WebKit, tinycc) that this
# -bin IDE package does not ship.
LICENSE="all-rights-reserved"
SLOT="0"
# As of the 1.1 release ("Agent Artifacts and Native ARM64 Builds", 2026-09-14)
# upstream publishes a native linux-arm64 .deb alongside linux-x64
# (prod.download.desktop.kiro.dev/releases/stable/linux-arm64/...), so the
# previous amd64-only restriction no longer applies; verified by fetching and
# extracting both the 1.1.14 amd64 and arm64 .deb artifacts directly.
KEYWORDS="~amd64 ~arm64"
IUSE="kerberos"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

# RDEPEND re-checked for 1.1.14 against both the amd64 and arm64 .deb
# Depends: fields plus a QA_PREBUILT audit; the package list is unchanged
# from the previous release and still matches app-editors/cursor's
# Chromium/Electron (Code - OSS fork) dependency set almost 1:1 (Kiro is,
# like Cursor, a VS Code / Code-OSS fork). The arm64 .deb additionally lists
# libstdc++6 in Depends; it is intentionally not listed here, matching
# established practice for other prebuilt Gentoo binaries in this overlay
# (see dev-util/github-copilot-cli-bin) -- libstdc++ is provided by the
# always-present system toolchain (sys-devel/gcc, part of @system).
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
