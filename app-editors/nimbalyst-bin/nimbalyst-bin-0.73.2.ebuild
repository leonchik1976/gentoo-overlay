# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils xdg

DESCRIPTION="Visual workspace for the Claude Code, Codex, and OpenCode coding agents"
HOMEPAGE="https://nimbalyst.com/ https://github.com/nimbalyst/nimbalyst"
SRC_URI="https://github.com/nimbalyst/nimbalyst/releases/download/v${PV}/Nimbalyst-Linux.AppImage -> ${P}.AppImage"
S="${WORKDIR}/squashfs-root"

# Nimbalyst's own code is MIT (verified against upstream LICENSE/LICENSING.md).
# The AppImage additionally bundles ~900 npm packages; upstream's own
# generated audit (resources/legal/THIRD_PARTY_LICENSE_AUDIT.md, reviewed
# directly inside the extracted AppImage for v0.73.2) accounts for all of
# them as permissive (MIT/ISC/Apache-2.0/BSD-3/BSD-2/BlueOak-1.0.0/CC0-1.0/
# Unlicense/0BSD), one file-level-copyleft EPL-2.0 dep (elkjs, unmodified),
# one dynamically-loaded LGPL-3.0 dep (libheif-js), one Python-2.0-licensed
# transitive dep (argparse, mapped to Gentoo's PYTHON license file), and one
# proprietary exception: @anthropic-ai/claude-agent-sdk, whose bundled
# "claude" CLI binary is (c) Anthropic PBC, all rights reserved
# ("Use is subject to the Legal Agreements outlined here:
# https://code.claude.com/docs/en/legal-and-compliance", per that
# component's own LICENSE.md), under Anthropic's Commercial Terms of
# Service (https://www.anthropic.com/legal/commercial-terms). Represented
# below with Gentoo's stock all-rights-reserved license, same as
# net-im/discord/app-editors/cursor/app-editors/kiro in this overlay. That
# component is why this can't be a plain MIT package.
LICENSE="MIT Apache-2.0 BSD BSD-2 ISC BlueOak-1.0.0 CC0-1.0 Unlicense 0BSD
	EPL-2.0 LGPL-3 PYTHON all-rights-reserved"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. Upstream's own CI
# (.github/workflows/electron-build.yml) only builds Linux on a single
# ubuntu-latest/x64 matrix job -- there is no Linux arm64 job at all (unlike
# macOS and Windows, which both get dedicated arm64 jobs). Confirmed
# empirically too: the v0.73.2 AppImage and every native .node addon and
# vendored CLI binary inside it (better-sqlite3, node-pty, @img/sharp,
# claude-agent-sdk-linux-x64, codex-linux-x64, codex-acp-linux-x64) is
# linux-x64/linuxmusl-x64 only.
KEYWORDS="-* ~amd64"
IUSE="appindicator"
# The bundled binaries are hard-linked against glibc's dynamic linker
# (interpreter /lib64/ld-linux-x86-64.so.2, confirmed via `file`), not just
# glibc-preferring; they cannot run on musl at all. Same constraint and fix
# as app-editors/kiro in this overlay.
REQUIRED_USE="elibc_glibc"
# bindist: bundled libffmpeg.so includes patent-encumbered H.264/AAC decoders
#          (confirmed via `strings libffmpeg.so`), same reasoning as
#          net-im/discord and app-office/obsidian.
# mirror:  the bundled proprietary Anthropic component (see LICENSE above)
#          is not ours to redistribute via Gentoo mirrors; fetch from
#          upstream's own GitHub release only.
# strip:   binaries are prebuilt and already stripped upstream.
RESTRICT="bindist mirror strip"

# RDEPEND verified 2026-08-21 with `readelf -d` against every ELF binary and
# .so extracted from the real v0.73.2 AppImage (main binary, chrome-sandbox,
# chrome_crashpad_handler, libEGL.so, libGLESv2.so, libvk_swiftshader.so,
# libvulkan.so.1, libffmpeg.so, and the bundled native npm addons). This is
# the same Chromium/Electron runtime dependency set already used by
# app-office/obsidian and net-im/beeper in ::guru, plus virtual/udev which
# is a direct NEEDED entry of the main binary here (libudev.so.1) but isn't
# listed by those two. @img/sharp's bundled libvips-cpp.so.8.17.3 resolves
# via its own $ORIGIN-relative RPATH, so unlike net-im/beeper this package
# does NOT need a symlink to media-libs/vips.
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	appindicator? ( dev-libs/libayatana-appindicator )
"

QA_PREBUILT="*"

NIMBALYST_BIN="@nimbalystelectron"

src_unpack() {
	cp "${DISTDIR}/${P}.AppImage" "${WORKDIR}/${P}.AppImage" || die
	chmod +x "${WORKDIR}/${P}.AppImage" || die

	cd "${WORKDIR}" || die
	# AppImages are self-extracting; this only unpacks the embedded squashfs
	# to ${WORKDIR}/squashfs-root and does not touch the network.
	"./${P}.AppImage" --appimage-extract >/dev/null || die "Failed to extract AppImage"
}

src_prepare() {
	default

	pushd locales >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	dodir /opt/nimbalyst
	cp -ar . "${D}/opt/nimbalyst/" || die

	# Multi-MB upstream license dumps we don't need at runtime; the
	# composite LICENSE= above already documents what's bundled.
	rm -f "${D}/opt/nimbalyst/LICENSE.electron.txt" \
		"${D}/opt/nimbalyst/LICENSES.chromium.html" || die

	# musl-target prebuilds of native addons that ship alongside the
	# linux-x64 (glibc) ones npm-side for portability. This package requires
	# elibc_glibc, so these are dead weight that only trips pkgcheck's
	# unresolved-soname-dependency QA check (they need libc.musl-x86_64.so.1,
	# which nothing here provides or ever loads). Same reasoning net-im/beeper
	# already applies to its own bundled classic-level.musl.node. Note this
	# is unrelated to the @openai/codex-linux-x64 musl-target vendor tree,
	# which is statically linked and must stay.
	rm -rf "${D}/opt/nimbalyst/resources/app.asar.unpacked/node_modules/@img/sharp-linuxmusl-x64" \
		"${D}/opt/nimbalyst/resources/app.asar.unpacked/node_modules/@img/sharp-libvips-linuxmusl-x64" || die
	rm -f "${D}/opt/nimbalyst/resources/node_modules/better-sqlite3/prebuilds/linuxmusl-x64.node" || die

	fowners root /opt/nimbalyst/chrome-sandbox
	fperms 4711 /opt/nimbalyst/chrome-sandbox
	pax-mark m "${ED}/opt/nimbalyst/${NIMBALYST_BIN}"

	dosym ../nimbalyst/${NIMBALYST_BIN} /opt/bin/nimbalyst

	sed \
		-e "s|^Exec=.*|Exec=nimbalyst %U|" \
		-e "s|^Icon=.*|Icon=nimbalyst|" \
		-e "/^X-AppImage-Version=/d" \
		-e "s|^MimeType=.*|MimeType=text/markdown;x-scheme-handler/nimbalyst;|" \
		-e "s|^Categories=.*|Categories=Development;Utility;|" \
		"${NIMBALYST_BIN}.desktop" >"${T}/nimbalyst.desktop" || die
	domenu "${T}/nimbalyst.desktop"

	local size
	for size in 16 32 48 64 128 256 512 1024; do
		newicon -s ${size} \
			"usr/share/icons/hicolor/${size}x${size}/apps/${NIMBALYST_BIN}.png" \
			nimbalyst.png
	done

	if use appindicator; then
		dosym ../../usr/lib64/libayatana-appindicator3.so \
			/opt/nimbalyst/libappindicator3.so
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	einfo "Nimbalyst bundles a proprietary copy of Anthropic's Claude Agent"
	einfo "SDK/CLI (all rights reserved, Anthropic Commercial Terms of"
	einfo "Service) and an Apache-2.0 OpenAI Codex SDK/CLI. See"
	einfo "  ${EROOT}/opt/nimbalyst/resources/legal/THIRD_PARTY_NOTICES.txt"
	einfo "for the full bundled third-party license inventory."
}
