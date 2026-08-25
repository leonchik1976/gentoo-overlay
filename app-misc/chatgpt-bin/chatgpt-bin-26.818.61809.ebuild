# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="ChatGPT desktop application for Linux"
HOMEPAGE="https://learn.chatgpt.com/docs/linux/linux-app"
SRC_URI="
	amd64? (
		https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${PV}_amd64.deb
		-> ${P}-amd64.deb
	)
	arm64? (
		https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${PV}_arm64.deb
		-> ${P}-arm64.deb
	)
"

S="${WORKDIR}"

LICENSE="all-rights-reserved MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libusb:1
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-misc/xdg-utils
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
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
	x11-libs/pango
"

QA_PREBUILT="usr/lib/chatgpt/*"

src_unpack() {
	unpack_deb "${A}"
}

src_prepare() {
	default

	local node_arch
	case ${ARCH} in
		amd64) node_arch=x64 ;;
		arm64) node_arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	# The application bundles native Node modules for several operating
	# systems, libc implementations, and architectures.  Keep only the
	# native glibc payload to avoid installing unusable binaries.
	local device_modules="usr/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/node_modules/@worklouder/wl-device-kit/node_modules"
	find "${device_modules}/node-hid/prebuilds" -mindepth 1 -maxdepth 1 \
		-type d ! -name "HID-linux-${node_arch}" \
		! -name "HID_hidraw-linux-${node_arch}" -exec rm -r {} + || die
	find "${device_modules}/serialport/node_modules/@serialport/bindings-cpp/prebuilds" \
		-mindepth 1 -maxdepth 1 -type d ! -name "linux-${node_arch}" \
		-exec rm -r {} + || die
	rm -f "${device_modules}"/serialport/node_modules/@serialport/bindings-cpp/prebuilds/linux-x64/*.musl.node || die

	# Debian-specific integration is not useful on Gentoo.  In particular,
	# do not install the AppArmor profile managed by the Debian maintainer
	# scripts or lintian metadata.
	rm -r etc usr/share/lintian || die
}

src_install() {
	dodoc usr/share/doc/chatgpt/copyright
	rm -r usr/share/doc || die

	cp -a usr "${ED}" || die
}

pkg_postinst() {
	xdg_pkg_postinst

	einfo "Run chatgpt from a terminal or launch ChatGPT from the application menu."
}
