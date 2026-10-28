# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop xdg

MY_PN="${PN/-bin}"

DESCRIPTION="Cross-platform SQL and NoSQL database client"
HOMEPAGE="https://dbgate.org/ https://github.com/dbgate/dbgate"
SRC_URI="
	amd64? (
		https://github.com/dbgate/dbgate/releases/download/v${PV}/${MY_PN}-${PV}-linux_x86_64.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://github.com/dbgate/dbgate/releases/download/v${PV}/${MY_PN}-${PV}-linux_arm64.AppImage
			-> ${P}-arm64.AppImage
	)
"
S="${WORKDIR}/squashfs-root"

# DbGate itself is GPL-3. The remaining licenses cover bundled Electron,
# Chromium, and Node.js components.
LICENSE="
	GPL-3 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64
	Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2
	LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft
	Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	>=sys-libs/glibc-2.34
	virtual/udev
	virtual/zlib:=
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
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/DbGate/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	local appimage
	case ${ARCH} in
		amd64) appimage=${P}-amd64.AppImage ;;
		arm64) appimage=${P}-arm64.AppImage ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	cp "${DISTDIR}/${appimage}" "${WORKDIR}/DbGate.AppImage" || die
	chmod +x "${WORKDIR}/DbGate.AppImage" || die
	cd "${WORKDIR}" || die
	./DbGate.AppImage --appimage-extract || die "AppImage extraction failed"
}

src_prepare() {
	default

	# The AppImage cannot use a setuid sandbox, so its launcher disables the
	# Chromium sandbox. Restore the setuid helper when the payload provides it.
	sed -e '/^Exec=/c Exec=dbgate %U' \
		-e '/^X-AppImage-Version=/d' \
		-i dbgate.desktop || die

	local modules=resources/app.asar.unpacked/node_modules
	local node_arch=$(usex amd64 x64 arm64)
	local oracle_release=${modules}/oracledb/build/Release
	local oracle_version=26.0.0
	local addon

	# This release supplies SQLite prebuilds for both Linux architectures.
	[[ -f ${modules}/better-sqlite3/prebuilds/linux-${node_arch}.node ]] ||
		die "Missing SQLite prebuild for ${node_arch}"
	for addon in "${modules}/better-sqlite3/prebuilds/"*.node; do
		[[ ${addon##*/} == linux-${node_arch}.node ]] || rm "${addon}" || die
	done

	[[ -f ${oracle_release}/oracledb-${oracle_version}-linux-${node_arch}.node ]] ||
		die "Missing Oracle prebuild for ${node_arch}"
	for addon in "${oracle_release}/"*.node*; do
		[[ ${addon##*/} == oracledb-${oracle_version}-linux-${node_arch}.node* ]] ||
			rm "${addon}" || die
	done

	# The release still ships x64-only DuckDB/libSQL modules on arm64.
	# ssh2 uses its upstream JavaScript fallback without its x64 addon.
	rm -r "${modules}/@duckdb/node-bindings-linux-x64-musl" \
		"${modules}/@libsql/linux-x64-musl" || die
	if use arm64; then
		rm -r "${modules}/@duckdb/node-bindings-linux-x64" \
			"${modules}/@libsql/linux-x64-gnu" || die
		rm "${modules}/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node" || die
	fi
}

src_configure() {
	chromium_suid_sandbox_check_kernel_config
	default
}

src_install() {
	local size
	for size in 16 32 48 64 128 256 512; do
		doicon -s "${size}" \
			"usr/share/icons/hicolor/${size}x${size}/apps/dbgate.png"
	done
	domenu dbgate.desktop

	# AppRun and its root-level icon links are AppImage-only. The bundled
	# usr/lib directory on amd64 is only used by AppRun's LD_LIBRARY_PATH;
	# the installed application uses Gentoo's runtime libraries instead.
	rm -r .DirIcon AppRun dbgate.png dbgate.desktop usr || die

	insinto /opt/DbGate
	doins -r .

	fperms +x \
		/opt/DbGate/dbgate \
		/opt/DbGate/chrome_crashpad_handler \
		/opt/DbGate/libffmpeg.so \
		/opt/DbGate/libvk_swiftshader.so \
		/opt/DbGate/libvulkan.so.1
	if [[ -f ${ED}/opt/DbGate/chrome-sandbox ]]; then
		fperms 4711 /opt/DbGate/chrome-sandbox
	fi

	dosym ../../opt/DbGate/dbgate /usr/bin/dbgate
}

pkg_postinst() {
	xdg_pkg_postinst

	if use arm64; then
		ewarn "Upstream's arm64 release lacks native arm64 modules for"
		ewarn "DuckDB and libSQL; those database integrations do not work."
		ewarn "See https://github.com/dbgate/dbgate/issues/1384"
	fi
}
