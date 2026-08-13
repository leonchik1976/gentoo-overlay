# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw
	ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop xdg

DESCRIPTION="A privacy-first, open-source platform for knowledge management"
HOMEPAGE="https://logseq.com/ https://github.com/logseq/logseq"
SRC_URI="
	amd64? (
		https://github.com/logseq/logseq/releases/download/${PV}/Logseq-linux-x86_64-${PV}.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://github.com/logseq/logseq/releases/download/${PV}/Logseq-linux-arm64-${PV}.AppImage
			-> ${P}-arm64.AppImage
	)
"
S="${WORKDIR}/squashfs-root"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="wayland"

RESTRICT="bindist mirror splitdebug strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libaio
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-devel/gcc:*
	>=sys-libs/glibc-2.34
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
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

QA_PREBUILT="opt/logseq-desktop/*"

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

	cp "${DISTDIR}/${appimage}" "${WORKDIR}/Logseq.AppImage" || die
	chmod +x "${WORKDIR}/Logseq.AppImage" || die
	cd "${WORKDIR}" || die
	./Logseq.AppImage --appimage-extract || die "AppImage extraction failed"
}

src_prepare() {
	default

	# Upstream's arm64 AppImage incorrectly includes only the x86-64 ZVec
	# binding. Remove it rather than installing unusable foreign binaries.
	if use arm64; then
		rm -r resources/app.asar.unpacked/node_modules/@zvec/bindings-linux-x64 || die
	fi

	pushd locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die
}

src_configure() {
	chromium_suid_sandbox_check_kernel_config
	default
}

src_install() {
	newicon -s 512 usr/share/icons/hicolor/0x0/apps/logseq.png logseq.png

	rm -r .DirIcon AppRun usr || die
	rm logseq.desktop logseq.png || die

	dodir /opt/logseq-desktop
	cp -a . "${ED}/opt/logseq-desktop/" || die

	fowners root:root /opt/logseq-desktop/chrome-sandbox
	fperms 4711 /opt/logseq-desktop/chrome-sandbox
	dosym ../../opt/logseq-desktop/logseq /usr/bin/logseq

	local exec_extra_flags=()
	if use wayland; then
		exec_extra_flags+=( "--ozone-platform-hint=auto" "--enable-wayland-ime" )
	fi
	make_desktop_entry --eapi9 logseq -a "${exec_extra_flags[*]} %U" -n Logseq \
		-i logseq -c Office -e "Terminal=false" -e "MimeType=x-scheme-handler/logseq"
}

pkg_postinst() {
	xdg_pkg_postinst

	ewarn "Logseq 2.0 is currently an upstream beta release. Back up important data"
	ewarn "before opening a graph with it. Logseq OG remains available in SLOT=1."
	if use arm64; then
		ewarn "Upstream's arm64 AppImage lacks a native arm64 ZVec binding; vector"
		ewarn "search functionality may be unavailable on arm64."
	fi
}
