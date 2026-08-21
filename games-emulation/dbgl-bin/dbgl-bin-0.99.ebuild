# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
MY_PN=${PN%-bin}

inherit java-pkg-2

DESCRIPTION="Multi-platform frontend/launcher for DOSBox and its variants"
HOMEPAGE="https://dbgl.org/"
SRC_URI="https://dbgl.org/download/${MY_PN}${PV/./}.tar.xz"
S="${WORKDIR}"

# Upstream ships a Linux archive bundling a prebuilt SWT native binding
# (lib/swtlin64.jar) that contains x86_64-only ELF shared objects; no
# linux-arm64 SWT jar is offered, so this package cannot be keyworded
# ~arm64 until upstream publishes one.
#
# Bundled-jar license audit (per-jar findings, evidence) is in
# docs/dbgl-bin-license-audit.md at the repo root. Summary: dbgl.jar itself
# is plain GPL-2 (not "+"); swtlin64.jar/gallery/jersey are EPL-2.0;
# hsqldb.jar's license has no ::gentoo match, mirrored to licenses/HSQLDB;
# json.jar matches Gentoo's stock JSON file; the Apache Commons jars are
# Apache-2.0.
LICENSE="GPL-2 EPL-2.0 HSQLDB JSON Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

# GUI deps verified via `readelf -d` against the bundled SWT native
# bindings (mandatory GTK3/cairo/atk/glib set); full evidence in
# docs/dbgl-bin-license-audit.md. Optional SWT bindings (OpenGL canvas,
# embedded browser, AWT bridge) aren't confirmed as actually used by DBGL,
# so their deps are deliberately not added.
RDEPEND="
	|| (
		virtual/jre:25
		virtual/jre:21
		virtual/jre:17
	)
	|| (
		games-emulation/dosbox
		games-emulation/dosbox-staging
	)
	app-accessibility/at-spi2-core
	dev-libs/glib:2
	x11-libs/cairo
	x11-libs/gtk+:3
"

src_install() {
	java-pkg_dojar "${MY_PN}.jar"
	java-pkg_jarinto "/usr/share/${PN}/lib/lib"
	java-pkg_dojar lib/*.jar

	java-pkg_dolauncher "${MY_PN}" \
		--jar "${MY_PN}.jar" \
		--java_args "-Ddbgl.data.userhome=true" \
		--pwd "/usr/share/${PN}/lib"

	insinto "/usr/share/${PN}"
	doins -r templates xsl
	doins "${MY_PN}.png"
}
