# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# xdg.eclass does not yet support EAPI 9.
EAPI=8

inherit desktop xdg

DESCRIPTION="Share files with nearby devices over the local network (upstream binary)"
HOMEPAGE="https://localsend.org https://github.com/localsend/localsend"
SRC_URI="
	amd64? ( https://github.com/localsend/localsend/releases/download/v${PV}/LocalSend-${PV}-linux-x86-64.tar.gz )
	arm64? ( https://github.com/localsend/localsend/releases/download/v${PV}/LocalSend-${PV}-linux-arm-64.tar.gz )
"
S="${WORKDIR}"

# Covers shipped Flutter notices and the locked Rust library dependency graph.
# Unmasked for personal use; audit limitations are documented in review notes.
LICENSE="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 FTL HPND IJG ISC MIT MPL-2.0 Old-MIT
	SGI-B-2.0 UoI-NCSA Unicode-3.0 Unicode-DFS-2016 ZLIB icu libpng2
	|| ( MIT Unlicense )
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/ayatana-ido
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/libayatana-indicator:3
	dev-libs/libdbusmenu
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	>=sys-libs/glibc-2.34
	sys-devel/gcc:*
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X,wayland]
	x11-libs/pango
"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="opt/localsend/*"

src_prepare() {
	default

	# JNI is pulled in by path_provider_android. Linux uses path_provider_linux;
	# no Linux plugin or native library links to this unused JVM helper.
	rm lib/libdartjni.so || die

	# Remove upstream CI paths; all bundled libraries live beside each other.
	local library
	for library in lib/*.so; do
		patchelf --set-rpath '$ORIGIN' "${library}" || die
	done
}

src_install() {
	exeinto /opt/localsend
	doexe localsend_app
	exeinto /opt/localsend/lib
	doexe lib/*.so
	insinto /opt/localsend
	doins -r data

	newbin "${FILESDIR}/localsend" localsend
	sed -i "s|@EPREFIX@|${EPREFIX}|g" "${ED}/usr/bin/localsend" || die

	local size
	for size in 32 128 256 512; do
		newicon -s "${size}" "data/flutter_assets/assets/img/logo-${size}.png" localsend.png
	done
	make_desktop_entry --eapi9 localsend -n LocalSend -i localsend \
		-d org.localsend.localsend_app -c "Network;FileTransfer;"

	# Preserve the complete notices as a readable documentation file too.
	gzip -dc data/flutter_assets/NOTICES.Z > "${T}/NOTICES" || die
	dodoc "${T}/NOTICES" data/flutter_assets/assets/CHANGELOG.md
	(
		mkdir -p "${T}/rust-notices" || die
		cd "${T}/rust-notices" || die
		unpack "${FILESDIR}/localsend-${PV}-rust-notices.tar.xz"
	) || die "Failed to unpack Rust notices"
	dodoc -r "${T}/rust-notices"
}
