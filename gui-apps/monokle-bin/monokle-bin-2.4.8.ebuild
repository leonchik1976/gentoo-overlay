# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop unpacker xdg

MY_PN="Monokle"

DESCRIPTION="Desktop IDE for working with Kubernetes clusters and YAML configurations"
HOMEPAGE="
	https://monokle.io/
	https://github.com/kubeshop/monokle
"
SRC_URI="
	amd64? (
		https://github.com/kubeshop/monokle/releases/download/v${PV}/${MY_PN}-linux-${PV}-amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://github.com/kubeshop/monokle/releases/download/v${PV}/${MY_PN}-linux-${PV}-arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

# Upstream's own MIT LICENSE file governs the Monokle application code; the
# bundled Electron/Chromium runtime carries its own separate licenses (see
# LICENSE.electron.txt and LICENSES.chromium.html installed alongside it).
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	elibc_glibc? ( sys-libs/glibc )
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxshmfence
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/monokle/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd "opt/${MY_PN}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	gunzip usr/share/doc/monokle/changelog.gz || die

	# Launch via the stable command in PATH, independent of the /opt layout.
	sed -i -e "/^Exec=/c Exec=monokle %U" \
		usr/share/applications/${MY_PN}.desktop || die
}

src_install() {
	# The only shipped icon lives under a non-standard "0x0" hicolor size
	# directory (an artifact of upstream's FPM-based .deb packaging); the
	# actual image is 512x512.
	doicon -s 512 "usr/share/icons/hicolor/0x0/apps/${MY_PN}.png"
	domenu usr/share/applications/${MY_PN}.desktop
	dodoc usr/share/doc/monokle/changelog

	insinto /opt/monokle
	doins -r "opt/${MY_PN}"/.

	fperms +x \
		/opt/monokle/${MY_PN} \
		/opt/monokle/chrome_crashpad_handler \
		/opt/monokle/libEGL.so \
		/opt/monokle/libGLESv2.so \
		/opt/monokle/libffmpeg.so \
		/opt/monokle/libvk_swiftshader.so \
		/opt/monokle/libvulkan.so.1
	fperms 4755 /opt/monokle/chrome-sandbox

	dosym -r /opt/monokle/${MY_PN} /usr/bin/monokle
}
