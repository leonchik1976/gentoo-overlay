# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw
	ta te th tr uk ur vi zh-CN zh-TW
"

# Build-time-only helper (files/asar-strip-dict.py, invoked from
# src_prepare); python-any-r1 is the correct eclass for this since no
# Python is needed at runtime by the installed package itself.
PYTHON_COMPAT=( python3_{12..15} )

inherit chromium-2 desktop pax-utils python-any-r1 xdg

DESCRIPTION="A Markdown editor with a focus on academic writing and knowledge management"
HOMEPAGE="https://www.zettlr.com/ https://github.com/Zettlr/Zettlr"
SRC_URI="
	amd64? (
		https://github.com/Zettlr/Zettlr/releases/download/v${PV}/Zettlr-${PV}-x86_64.AppImage
			-> ${P}-amd64.AppImage
	)
	arm64? (
		https://github.com/Zettlr/Zettlr/releases/download/v${PV}/Zettlr-${PV}-arm64.AppImage
			-> ${P}-arm64.AppImage
	)
"
S="${WORKDIR}/squashfs-root"

# Full bundled-license audit is in docs/zettlr-bin-license-audit.md at the
# repo root (kept out of the ebuild body since it's long). Summary:
# Zettlr's own code is GPL-3; Electron/Chromium + npm deps are MIT/BSD;
# resources/pandoc is GPL-2+; bundled Hunspell dictionaries are ISC/BSD,
# all already covered by the above except the (removed) tr-TR one -- see
# src_prepare() below.
LICENSE="GPL-3 GPL-2+ MIT BSD MPL-2.0 ISC"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# bindist: bundled libffmpeg.so contains patent-encumbered H.264/AAC decoders
#          (confirmed via `strings libffmpeg.so`, e.g. ff_h264_decoder,
#          ff_aac_decoder), same reasoning as app-editors/nimbalyst-bin.
# mirror:  large prebuilt upstream binary blob (~190MB), not something to
#          push onto Gentoo mirrors.
# strip:   binary is prebuilt and already stripped upstream.
RESTRICT="bindist mirror strip"

BDEPEND="${PYTHON_DEPS}"

# RDEPEND verified 2026-08-21 with `readelf -d` against every ELF binary and
# .so in the real v4.7.0 arm64 AppImage (Zettlr, chrome-sandbox,
# chrome_crashpad_handler, libEGL.so, libGLESv2.so, libvk_swiftshader.so,
# libvulkan.so.1, libffmpeg.so, and the bundled Nodehun.node spellcheck
# addon) -- the same Chromium/Electron runtime set already used by
# app-editors/nimbalyst-bin and app-editors/logseq-desktop-bin in this
# overlay.
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-devel/gcc:*
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="*"

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

	cp "${DISTDIR}/${appimage}" "${WORKDIR}/Zettlr.AppImage" || die
	chmod +x "${WORKDIR}/Zettlr.AppImage" || die
	cd "${WORKDIR}" || die
	# AppImages are self-extracting; this only unpacks the embedded squashfs
	# to ${WORKDIR}/squashfs-root and does not touch the network.
	./Zettlr.AppImage --appimage-extract >/dev/null || die "AppImage extraction failed"
}

src_prepare() {
	default

	pushd locales >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die

	# Strip the bundled tr-TR Hunspell dictionary, which ships with no
	# resolvable license (see docs/zettlr-bin-license-audit.md). Pure
	# stdlib Python .asar surgery, no node/npm/network involved; every
	# surviving file's bytes are verified against its own stored SHA256
	# integrity hash (whole-file and per-block) as part of every run, not
	# just a one-off check done before this was wired in.
	"${PYTHON}" "${FILESDIR}/asar-strip-dict.py" resources/app.asar tr-TR || die
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	newicon -s 512 usr/share/icons/hicolor/512x512/apps/Zettlr.png zettlr.png

	rm -r .DirIcon AppRun usr || die
	rm Zettlr.desktop Zettlr.png || die

	dodir /opt/zettlr
	cp -a . "${ED}/opt/zettlr/" || die
	find "${ED}/opt/zettlr" -type d -exec chmod 0755 {} + || die

	fowners root:root /opt/zettlr/chrome-sandbox
	fperms 4711 /opt/zettlr/chrome-sandbox
	pax-mark m "${ED}/opt/zettlr/Zettlr"

	dosym ../zettlr/Zettlr /opt/bin/zettlr

	make_desktop_entry --eapi9 zettlr -n "Zettlr" -i zettlr -c "Office" \
		-a "%U" -e "MimeType=text/markdown;"
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
