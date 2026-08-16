# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN=github-copilot

DESCRIPTION="Agent-native desktop app for running and steering Copilot coding tasks"
HOMEPAGE="
	https://github.com/features/ai/github-app
	https://github.com/github/app
"
SRC_URI="
	amd64? ( https://github.com/github/app/releases/download/v${PV}/GitHub-Copilot-linux-x64.deb )
	arm64? ( https://github.com/github/app/releases/download/v${PV}/GitHub-Copilot-linux-arm64.deb )
"
S="${WORKDIR}"

# github/app is a release-only repository (README/changelog/License.md, no
# source); License.md is just "(c) GitHub, Inc. All rights reserved." with
# no further terms, i.e. the generic Gentoo all-rights-reserved case.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"

# Verified by extracting both the amd64 and arm64 v1.1.10 .deb assets
# directly (dpkg-deb -x/-e) rather than assuming an Electron-style
# dependency set: control file reports "Tauri Copilot Application", and
# `readelf -d` on usr/bin/github confirms a WebKitGTK app (libwebkit2gtk-
# 4.1/libjavascriptcoregtk-4.1), not Chromium/Electron -- there is no
# chrome-sandbox helper and no CONFIG_CHECK=~USER_NS requirement here,
# unlike app-office/obsidian or net-im/discord-canary-bin in ::guru.
# The package also bundles a large (~220MB) local ONNX Runtime GenAI
# engine (libonnxruntime*.so, Microsoft.AI.Foundry.Local.Core.so),
# installed directly under /opt/${MY_PN}, for on-device inference; they
# are not linked by usr/bin/github itself (absent from its NEEDED list).
# Every bundled ELF object (not just usr/bin/github) was individually
# checked with `readelf -d` on both the amd64 and arm64 v1.1.10 assets,
# and each one's external NEEDED entries are covered by RDEPEND below.
# native-plugins/libgithub_app_linux_pulse_plugin.so (a Tauri plugin) is
# the one bundled object with NEEDED entries not already pulled in by
# usr/bin/github's own linkage: it separately requires libpulse.so.0 and
# libpulse-simple.so.0, hence media-libs/libpulse below.
#
# Direct NEEDED entries -> Gentoo packages:
#   libasound.so.2                         media-libs/alsa-lib
#   libgdk-3.so.0, libgtk-3.so.0            x11-libs/gtk+:3
#   libpango-1.0.so.0, libpangocairo-...    x11-libs/pango
#   libharfbuzz.so.0                        media-libs/harfbuzz
#   libgdk_pixbuf-2.0.so.0                  x11-libs/gdk-pixbuf:2
#   libcairo.so.2, libcairo-gobject.so.2    x11-libs/cairo
#   libgobject/glib/gmodule/gio-2.0.so.0    dev-libs/glib:2
#   libdbus-1.so.3                          sys-apps/dbus
#   libwebkit2gtk-4.1.so.0,
#     libjavascriptcoregtk-4.1.so.0         net-libs/webkit-gtk:4.1
#   libatk-1.0.so.0                         app-accessibility/at-spi2-core (dev-libs/atk is
#                                            merged/deprecated upstream in ::gentoo)
#   libsoup-3.0.so.0                        net-libs/libsoup:3.0
#   libssl.so.3, libcrypto.so.3             dev-libs/openssl:0=
#   libc.so.6, architecture-specific ld-linux  sys-libs/glibc
#   (native-plugins/libgithub_app_linux_pulse_plugin.so only)
#   libpulse.so.0, libpulse-simple.so.0     media-libs/libpulse
# libayatana-appindicator3-1 is not in usr/bin/github's NEEDED list (it is
# presumably dlopen'd for the tray icon, as with app-office/obsidian's
# optional appindicator USE flag) but is listed as a hard Depends in both
# .deb control files, so it is kept unconditional here rather than
# USE-gated, matching upstream's own declared requirement.
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/openssl:0=
	media-libs/alsa-lib
	media-libs/harfbuzz
	media-libs/libpulse
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"

QA_PREBUILT="*"

src_install() {
	insinto /opt/${MY_PN}
	doins -r "usr/lib/GitHub Copilot"/.

	exeinto /opt/${MY_PN}
	doexe usr/bin/github usr/bin/git-credential-copilot

	# Both the .desktop file's Exec= and the x-scheme-handler/{github-app,
	# ghapp,gh} URL-handler registration require the binary to be reachable
	# on PATH under upstream's exact name "github" -- renaming it here
	# would silently break URL-scheme launching from the browser/git.
	dosym ../../opt/${MY_PN}/github usr/bin/github
	dosym ../../opt/${MY_PN}/git-credential-copilot usr/bin/git-credential-copilot

	# Upstream ships this as "GitHub Copilot.desktop" (with a space); give
	# it a normal filename via newmenu instead of domenu.
	newmenu "usr/share/applications/GitHub Copilot.desktop" ${PN}.desktop

	# Installed as-is (including the 256x256@2 HiDPI variant) rather than
	# per-size doicon calls, since doicon has no clean way to express the
	# "@2" scale suffix in the hicolor spec.
	insinto /usr/share/icons/hicolor
	doins -r usr/share/icons/hicolor/.
}
