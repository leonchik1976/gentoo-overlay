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
# Match the runtime and SQLite addon in the upstream release's package-lock.json.
ELECTRON_PV="24.8.8"
SQLITE_PV="5.1.7"
SRC_URI="
	https://github.com/sqlectron/sqlectron/releases/download/v${PV}/${PN}_${PV}_amd64.deb
		-> ${P}-amd64.deb
	arm64? (
		https://github.com/electron/electron/releases/download/v${ELECTRON_PV}/electron-v${ELECTRON_PV}-linux-arm64.zip
		https://github.com/TryGhost/node-sqlite3/releases/download/v${SQLITE_PV}/sqlite3-v${SQLITE_PV}-napi-v6-linux-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

BDEPEND+=" arm64? ( app-arch/unzip )"

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

src_unpack() {
	# The .deb supplies the architecture-independent app bundle and desktop files.
	unpacker "${P}-amd64.deb"

	if use arm64; then
		mkdir electron-arm64 sqlite-arm64 || die
		pushd electron-arm64 >/dev/null || die
		unpack "electron-v${ELECTRON_PV}-linux-arm64.zip"
		popd >/dev/null || die
		pushd sqlite-arm64 >/dev/null || die
		unpack "sqlite3-v${SQLITE_PV}-napi-v6-linux-arm64.tar.gz"
		popd >/dev/null || die
	fi
}

src_prepare() {
	default

	if use arm64; then
		mv "${SQLECTRON_HOME}" sqlectron-amd64 || die
		mv electron-arm64 "${SQLECTRON_HOME}" || die
		mv "${SQLECTRON_HOME}/electron" "${SQLECTRON_HOME}/sqlectron" || die
		mv sqlectron-amd64/resources/app.asar{,.unpacked} \
			"${SQLECTRON_HOME}/resources/" || die

		local modules="${SQLECTRON_HOME}/resources/app.asar.unpacked/node_modules"
		cp sqlite-arm64/build/Release/node_sqlite3.node \
			"${modules}/sqlite3/build/Release/node_sqlite3.node" || die
		# ssh2 catches failure to load these optional native accelerators and
		# uses its JavaScript/WASM crypto and default cipher ordering instead.
		rm "${modules}/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node" \
			"${modules}/cpu-features/build/Release/cpufeatures.node" || die
	fi

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
