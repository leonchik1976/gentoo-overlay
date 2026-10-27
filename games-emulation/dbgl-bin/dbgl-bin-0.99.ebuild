# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9
MY_PN=${PN%-bin}
SWT_PV=4.33
SWT_BUILD=R-${SWT_PV}-202409030240

inherit java-pkg-2

DESCRIPTION="Multi-platform frontend/launcher for DOSBox and its variants"
HOMEPAGE="https://dbgl.org/"
SRC_URI="
	https://dbgl.org/download/${MY_PN}${PV/./}.tar.xz
	arm64? (
		https://archive.eclipse.org/eclipse/downloads/drops4/${SWT_BUILD}/swt-${SWT_PV}-gtk-linux-aarch64.zip
	)
"
S="${WORKDIR}"

# Upstream's Linux archive bundles x86_64 SWT. For arm64, replace the whole
# jar with Eclipse's matching SWT 4.33 (native version 4966r5) build.
#
# Bundled-jar license audit (per-jar findings, evidence) is in
# docs/dbgl-bin-license-audit.md at the repo root. Summary: dbgl.jar itself
# is plain GPL-2 (not "+"); swtlin64.jar/gallery/jersey are EPL-2.0;
# hsqldb.jar's license has no ::gentoo match, mirrored to licenses/HSQLDB;
# json.jar matches Gentoo's stock JSON file; the Apache Commons jars are
# Apache-2.0.
LICENSE="GPL-2 EPL-2.0 HSQLDB JSON Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror"

# GUI deps verified via `readelf -d` against the bundled SWT native
# bindings (mandatory GTK3/cairo/atk/glib set); full evidence in
# docs/dbgl-bin-license-audit.md. Optional SWT bindings (OpenGL canvas,
# embedded browser, AWT bridge) aren't confirmed as actually used by DBGL,
# so their deps are deliberately not added.
BDEPEND+=" arm64? ( app-arch/unzip )"

RDEPEND+="
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

src_unpack() {
	unpack "${MY_PN}${PV/./}.tar.xz"
	if use arm64; then
		mkdir swt || die
		cd swt || die
		unpack "swt-${SWT_PV}-gtk-linux-aarch64.zip"
	fi
}

src_prepare() {
	java-pkg-2_src_prepare
	if use arm64; then
		# Keep the filename expected by dbgl.jar's manifest Class-Path.
		cp swt/swt.jar lib/swtlin64.jar || die
	fi
}

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
