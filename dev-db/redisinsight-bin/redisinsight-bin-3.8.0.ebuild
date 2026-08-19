# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop unpacker xdg

MY_PN="Redis Insight"

DESCRIPTION="GUI for visualizing and optimizing data in Redis or Redis-compatible databases"
HOMEPAGE="
	https://redis.io/insight/
	https://github.com/redis/RedisInsight
"
SRC_URI="
	amd64? (
		https://github.com/redis/RedisInsight/releases/download/${PV}/Redis-Insight-linux-amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://github.com/redis/RedisInsight/releases/download/${PV}/Redis-Insight-linux-arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

# Source-available under the Server Side Public License; see
# licenses/SSPL-1 (already used by dev-db/mongodb in ::gentoo).
LICENSE="SSPL-1"
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

QA_PREBUILT="opt/redisinsight/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd "opt/${MY_PN}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	gunzip usr/share/doc/redisinsight/changelog.gz || die

	# Launch via the stable command in PATH, independent of the /opt layout.
	sed -i -e '/^Exec=/c Exec=redisinsight %U' \
		usr/share/applications/redisinsight.desktop || die
}

src_install() {
	local size
	for size in 16 24 32 48 64 96 128 256 512 1024; do
		doicon -s "${size}" \
			"usr/share/icons/hicolor/${size}x${size}/apps/redisinsight.png"
	done
	domenu usr/share/applications/redisinsight.desktop
	dodoc usr/share/doc/redisinsight/changelog

	insinto /opt/redisinsight
	doins -r "opt/${MY_PN}"/.

	fperms +x \
		/opt/redisinsight/redisinsight \
		/opt/redisinsight/chrome_crashpad_handler \
		/opt/redisinsight/libEGL.so \
		/opt/redisinsight/libGLESv2.so \
		/opt/redisinsight/libffmpeg.so \
		/opt/redisinsight/libvk_swiftshader.so \
		/opt/redisinsight/libvulkan.so.1
	fperms 4755 /opt/redisinsight/chrome-sandbox

	dosym -r /opt/redisinsight/redisinsight /usr/bin/redisinsight
}
