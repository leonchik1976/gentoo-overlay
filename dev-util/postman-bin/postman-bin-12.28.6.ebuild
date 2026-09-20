# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi
	fr gu he hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro
	ru sk sl sr sv sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils xdg

DESCRIPTION="API platform for building and using APIs"
HOMEPAGE="https://www.postman.com/"
SRC_URI="
	amd64? ( https://dl.pstmn.io/download/version/${PV}/linux64 -> ${P}-amd64.tar.gz )
	arm64? ( https://dl.pstmn.io/download/version/${PV}/linux_arm64 -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}/Postman/app"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="suid"
RESTRICT="bindist mirror splitdebug"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[X]
	net-print/cups
	sys-apps/dbus
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3[X]
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

QA_PREBUILT="
	opt/postman/chrome-sandbox
	opt/postman/chrome_crashpad_handler
	opt/postman/libEGL.so
	opt/postman/libGLESv2.so
	opt/postman/libffmpeg.so
	opt/postman/libvk_swiftshader.so
	opt/postman/libvulkan.so.1
	opt/postman/postman
	opt/postman/resources/app/node_modules/native_modules/*.node
	opt/postman/resources/app/node_modules/native_modules/build/Release/*.node
	opt/postman/resources/app/node_modules/native_modules/prebuilds/linux-*/*.node
	opt/postman/resources/app/node_modules/native_modules/rg
	opt/postman/resources/data/spawn-helper
"

pkg_pretend() {
	use suid || chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd locales >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die

	# This wrapper unconditionally launches Electron with --no-sandbox.
	rm Postman || die
	use suid || rm chrome-sandbox || die
}

src_install() {
	newicon -s 128 resources/app/assets/icon.png postman.png

	insinto /opt/postman
	doins -r .

	fperms +x \
		/opt/postman/chrome_crashpad_handler \
		/opt/postman/libEGL.so \
		/opt/postman/libGLESv2.so \
		/opt/postman/libffmpeg.so \
		/opt/postman/libvk_swiftshader.so \
		/opt/postman/libvulkan.so.1 \
		/opt/postman/postman \
		/opt/postman/resources/app/node_modules/native_modules/rg \
		/opt/postman/resources/app/node_modules/native_modules/swap_and_relaunch.sh \
		/opt/postman/resources/data/spawn-helper

	if use suid; then
		fperms u+s,+x /opt/postman/chrome-sandbox
	fi

	dosym ../../opt/postman/postman /usr/bin/postman
	pax-mark -m "${ED}"/opt/postman/postman

	make_desktop_entry --eapi9 postman \
		--args "%U" \
		--categories "Development;Utility;" \
		--desktopid postman \
		--entry "StartupNotify=true" \
		--entry "StartupWMClass=postman" \
		--entry "MimeType=x-scheme-handler/postman" \
		--icon postman \
		--name "Postman"
}
