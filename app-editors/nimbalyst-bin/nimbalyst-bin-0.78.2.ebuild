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

# The exact AppImage includes upstream's third-party license inventory.
# Anthropic's bundled agent makes this more than an MIT-only distribution.
LICENSE="MIT Apache-2.0 BSD BSD-2 ISC BlueOak-1.0.0 CC0-1.0 Unlicense 0BSD
	EPL-2.0 LGPL-3 PYTHON all-rights-reserved"
SLOT="0"
# Upstream supplies only a Linux amd64 AppImage; arm64 is unavailable.
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

# Electron runtime libraries and libraries used by bundled CLI executables.
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	sys-libs/libcap
	sys-libs/ncurses:0/6
	virtual/zlib
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

# ONNX Runtime loads these GPU providers only when explicitly selected.
# CPU inference does not require CUDA/TensorRT. Keep the upstream optional
# providers, without making their independent GPU stacks base dependencies.
REQUIRES_EXCLUDE="
	opt/nimbalyst/resources/node_modules/onnxruntime-node/bin/napi-v3/linux/x64/libonnxruntime_providers_cuda.so
	opt/nimbalyst/resources/node_modules/onnxruntime-node/bin/napi-v3/linux/x64/libonnxruntime_providers_tensorrt.so
"

NIMBALYST_BIN="nimbalyst"

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

	# Preserve the bundled Electron/Chromium license texts.
	dodoc LICENSE.electron.txt LICENSES.chromium.html
	# AppImage's GTK2 tray libraries are unused by our direct launcher;
	# USE=appindicator selects the system GTK3 Ayatana library below.
	rm -f "${ED}/opt/nimbalyst/usr/lib/libappindicator.so.1" \
		"${ED}/opt/nimbalyst/usr/lib/libindicator.so.7" || die

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

	# `cp -ar` preserves the AppImage's extracted directory modes, which are
	# 0700 root:root (squashfs stores upstream's build-time permissions
	# verbatim). Left as-is, ordinary users can't traverse /opt/nimbalyst at
	# all, so even the correctly-executable main binary is unreachable via
	# the /opt/bin/nimbalyst symlink. Normalize to world-readable/traversable
	# before the chrome-sandbox setuid correction below (which must stay
	# root:4711, not swept up by this).
	fperms -R a+rX /opt/nimbalyst

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
	for size in 16 24 32 48 64 128 256 512; do
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
