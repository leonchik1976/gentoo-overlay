# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop unpacker xdg

MY_PN="Lens"
MY_PV="${PV}-latest"

DESCRIPTION="Official Mirantis Kubernetes IDE"
HOMEPAGE="https://lenshq.io/ https://docs.k8slens.dev/"
SRC_URI="https://downloads.k8slens.dev/ide/${MY_PN}-${MY_PV}.amd64.deb"
S="${WORKDIR}"

LICENSE="
	APSL-2
	Apache-2.0
	Apache-2.0-with-LLVM-exceptions
	BSD
	BSD-2
	Base64
	Boost-1.0
	CC-BY-3.0
	CC-BY-4.0
	Clear-BSD
	FFT2D
	FTL
	IJG
	ISC
	LGPL-2
	LGPL-2.1
	MIT
	MPL-1.1
	MPL-2.0
	Ms-PL
	PSF-2
	SGI-B-2.0
	SSLeay
	SunSoft
	Unicode-3.0
	Unicode-DFS-2015
	Unity-Companion-1.3
	Unlicense
	UoI-NCSA
	ZLIB
	all-rights-reserved
	android
	libtiff
	openssl
	unRAR
"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	media-libs/alsa-lib
	media-libs/mesa
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/libudev
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="
	opt/Lens/chrome_crashpad_handler
	opt/Lens/chrome-sandbox
	opt/Lens/lens-desktop
	opt/Lens/libEGL.so
	opt/Lens/libffmpeg.so
	opt/Lens/libGLESv2.so
	opt/Lens/libvk_swiftshader.so
	opt/Lens/libvulkan.so.1
	opt/Lens/resources/app.asar.unpacked/node_modules/@azure/msal-node-runtime/dist/libmsalruntime.so
	opt/Lens/resources/app.asar.unpacked/node_modules/@azure/msal-node-runtime/dist/linux/x64/libmsalruntime.so
	opt/Lens/resources/app.asar.unpacked/node_modules/@azure/msal-node-runtime/dist/linux/x64/msal-node-runtime.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@azure/msal-node-runtime/dist/msal-node-runtime.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm-gnueabihf.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm64-gnu.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm64-musl.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-ia32-gnu.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-x64-gnu.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-x64-musl.node
	opt/Lens/resources/app.asar.unpacked/node_modules/keytar/build/Release/keytar.node
	opt/Lens/resources/app.asar.unpacked/node_modules/msgpackr-extract/bin/linux-x64-146/msgpackr-extract.node
	opt/Lens/resources/app.asar.unpacked/node_modules/msgpackr-extract/build/Release/extract.node
	opt/Lens/resources/app.asar.unpacked/node_modules/native-machine-id/bin/linux-x64-146/native-machine-id.node
	opt/Lens/resources/app.asar.unpacked/node_modules/native-machine-id/build/Release/native_machine_id.node
	opt/Lens/resources/app.asar.unpacked/node_modules/node-pty/bin/linux-x64-146/node-pty.node
	opt/Lens/resources/app.asar.unpacked/node_modules/node-pty/build/Release/pty.node
	opt/Lens/resources/cli/bin/lens-cli-linux-x64
	opt/Lens/resources/x64/helm
	opt/Lens/resources/x64/kubectl
	opt/Lens/resources/x64/lens-k8s-proxy
"

# The extract-zip module bundles variants for platforms other than Linux
# amd64/glibc. They are selected by platform at runtime and must not contribute
# foreign-ABI requirements to this amd64 package's dependency metadata.
REQUIRES_EXCLUDE="
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm-gnueabihf.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm64-gnu.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-arm64-musl.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-ia32-gnu.node
	opt/Lens/resources/app.asar.unpacked/node_modules/@electron-internal/extract-zip/index.linux-x64-musl.node
"

src_unpack() {
	unpack_deb "${A}"
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	dodir /opt
	cp -a opt/Lens "${ED}/opt/" || die
	fperms 4711 /opt/Lens/chrome-sandbox

	domenu usr/share/applications/lens-desktop.desktop
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/lens-desktop.png

	dosym ../../opt/Lens/lens-desktop /usr/bin/lens-desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Lens checks for application updates using its bundled updater."
	elog "Disable automatic updates in Lens preferences to keep updates under"
	elog "Portage control. The Debian build otherwise uses electron-updater's"
	elog "DebUpdater support."
}
