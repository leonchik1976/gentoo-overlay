# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# unpacker.eclass only supports EAPI 7/8 in this tree (case ${EAPI} in
# 7|8) ... *) die), so EAPI=9 is not available for a .deb-unpacking ebuild
# yet.

inherit desktop optfeature unpacker xdg

DESCRIPTION="Desktop application for Claude.ai"
HOMEPAGE="https://claude.ai https://code.claude.com/docs/en/desktop-linux"
SRC_URI="
	amd64? ( https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${PV}_amd64.deb -> ${P}_amd64.deb )
	arm64? ( https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${PV}_arm64.deb -> ${P}_arm64.deb )
"
S="${WORKDIR}"

# usr/share/doc/claude-desktop/copyright in the .deb: "Files: * / Copyright:
# Anthropic PBC / License: Proprietary", subject to Anthropic's Consumer
# Terms. The apt repo is unauthenticated-read but grants no redistribution
# rights, so this may not go on Gentoo's own mirrors.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="suid"
RESTRICT="bindist mirror"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-apps/xdg-desktop-portal
	virtual/libudev
	x11-libs/cairo
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
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
	|| (
		sys-apps/xdg-desktop-portal-gtk
		sys-apps/xdg-desktop-portal-gnome
		kde-plasma/xdg-desktop-portal-kde
	)
"

# xdg-desktop-portal plus one backend is upstream's own hard Depends (not
# Recommends) in the .deb: screen sharing and other portal-mediated
# Chromium/Electron calls are nonfunctional without one. This is a plain
# RDEPEND alternatives group with no USE flag attached, so it does not
# need PG0001's exception at all -- that policy only restricts *USE-flag*
# gating of optional runtime deps; an unconditional hard || group like
# this one is the ordinary case PG0001 doesn't touch. "Move to trash" is
# a single, genuinely optional capability by comparison -- see the
# trash-cli/gvfs/kde-cli-tools optfeature call in pkg_postinst instead of
# RDEPEND here.

QA_PREBUILT="opt/claude-desktop/chrome-sandbox
	opt/claude-desktop/chrome_crashpad_handler
	opt/claude-desktop/claude-desktop
	opt/claude-desktop/libEGL.so
	opt/claude-desktop/libGLESv2.so
	opt/claude-desktop/libffmpeg.so
	opt/claude-desktop/libvk_swiftshader.so
	opt/claude-desktop/libvulkan.so.1
	opt/claude-desktop/resources/app.asar.unpacked/node_modules/*
	opt/claude-desktop/resources/app.asar.unpacked/resources/github-mcp/github-mcp-server
	opt/claude-desktop/resources/chrome-native-host
	opt/claude-desktop/resources/cowork-linux-helper
	opt/claude-desktop/resources/virtiofsd"

src_install() {
	dodir /opt
	cp -a usr/lib/claude-desktop "${ED}/opt/claude-desktop" || die

	dosym -r /opt/claude-desktop/claude-desktop /usr/bin/claude-desktop

	local size
	for size in 16 32 48 128 256; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/claude-desktop.png
	done
	domenu usr/share/applications/com.anthropic.Claude.desktop

	dodoc usr/share/doc/claude-desktop/copyright

	# Upstream's own .deb ships this 4755 unconditionally ("belt-and-
	# suspenders" per its postinst comment). Default it off here instead:
	# most Gentoo kernels are built with CONFIG_USER_NS=y and no restrictive
	# kernel.unprivileged_userns_clone sysctl, which alone is enough for
	# Chromium's sandbox, and neither the kernel nor sys-apps/apparmor on a
	# Gentoo system carry Ubuntu's downstream AppArmor userns-restriction
	# patch that would otherwise block it -- but none of that is a given: a
	# hardened kernel config or an admin-set sysctl can still disable
	# unprivileged userns. Enable USE=suid if the sandbox reports it can't
	# start.
	if use suid; then
		fperms 4755 /opt/claude-desktop/chrome-sandbox
	else
		fperms 0755 /opt/claude-desktop/chrome-sandbox
	fi

	# Officially supported "managed configuration" policy file -- the
	# Linux counterpart of the macOS MDM plist / Windows GPO registry keys
	# the app also honors. Ships with the in-app updater permanently
	# disabled so upgrades only happen through Portage; see pkg_postinst
	# for the (narrow) side effect of setting this key this way.
	insinto /etc/claude-desktop
	doins "${FILESDIR}"/managed-settings.json
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "The in-app updater is disabled via the config-protected"
	elog "/etc/claude-desktop/managed-settings.json; Claude Desktop is"
	elog "updated only through Portage. Setting disableAutoUpdates there"
	elog "also moves the rest of that same settings group (e.g. the"
	elog "release-notes-nudge timer) to managed-only scope; unrelated"
	elog "settings groups are unaffected."
	elog
	optfeature "moving deleted files to trash instead of permanently deleting them" \
		app-misc/trash-cli gnome-base/gvfs kde-plasma/kde-cli-tools
	elog
	if [[ ${ARCH} == amd64 ]]; then
		elog "Cowork (sandboxed code execution) needs QEMU, UEFI firmware, and"
		elog "virtiofsd together. None are hard dependencies, since Cowork is an"
		elog "optional feature and this is a personal-overlay judgment call:"
		optfeature "Cowork sandboxed code execution" \
			"app-emulation/qemu[qemu_softmmu_targets_x86_64] sys-firmware/edk2-bin[qemu_softmmu_targets_x86_64] app-emulation/virtiofsd"
		elog "Cowork probes \$PATH (/usr/bin, /usr/libexec) for virtiofsd ahead"
		elog "of its own bundled copy, so app-emulation/virtiofsd above is"
		elog "picked up automatically once installed -- no configuration needed."
		elog
		elog "Cowork's firmware autodetection tries /usr/share/OVMF/OVMF_CODE_4M.fd,"
		elog "then falls back to /usr/share/OVMF/OVMF_CODE.fd. sys-firmware/edk2-bin"
		elog "ships the latter (plus the matching OVMF_VARS.fd) at"
		elog "/usr/share/edk2-ovmf, verified by extracting its binpkg; point Cowork"
		elog "at it with:"
		elog "  ln -s edk2-ovmf /usr/share/OVMF"
	else
		elog "Cowork (sandboxed code execution) is currently UNSUPPORTED on arm64"
		elog "by this ebuild -- do not install sys-firmware/edk2-bin expecting it"
		elog "to enable Cowork here, it will not. Cowork only looks for UEFI"
		elog "firmware at /usr/share/AAVMF/AAVMF_CODE.fd; as of"
		elog "sys-firmware/edk2-bin-202605 (verified by extracting its binpkg), the"
		elog "only arm64 firmware it packages is"
		elog "/usr/share/edk2/ArmVirtQemu-AARCH64/QEMU_EFI.qcow2 -- a different"
		elog "filename *and* a qcow2 image rather than the raw .fd file Cowork"
		elog "looks for, so no symlink bridges the gap. Chat and Claude Code are"
		elog "unaffected; only the optional Cowork sandbox is unavailable."
	fi
	elog
	optfeature "the system tray icon" dev-libs/libayatana-appindicator
}

pkg_postrm() {
	xdg_pkg_postrm
}
