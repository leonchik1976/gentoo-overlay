# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# xdg-utils.eclass and unpacker.eclass only support EAPI 7/8; desktop.eclass
# supports up to 9, so 8 is the newest EAPI usable by all three here.
EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Cisco's packet tracer"
HOMEPAGE="https://www.netacad.com/resources/lab-downloads"
SRC_URI="CiscoPacketTracer_901_Ubuntu_64bit.deb"

S="${WORKDIR}"

LICENSE="Cisco"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. The .deb's payload is an
# x86_64-only AppImage (confirmed via ELF inspection of every bundled binary
# during packaging) and Cisco publishes no arm64 Linux build of Packet
# Tracer.
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="fetch mirror strip"

# Upstream now ships a single .AppImage inside the .deb (opt/pt/packettracer.AppImage)
# instead of a plain unpacked tree as in 8.2.x. It bundles its own Qt6 (incl.
# QtWebEngine/Chromium) and OpenSSL, plus a handful of ABI-compat shim libraries
# under the AppImage's usr/lib (e.g. libtiff.so.5, libpcre2-16.so.0) for SONAMEs
# modern distros no longer ship. RDEPEND below lists only what is verified NOT
# bundled anywhere in the AppImage, derived from `readelf -d` NEEDED entries
# across every ELF object in the extracted image (see bug investigation notes).
#
# media-libs/alsa-lib, dev-libs/libxslt, media-libs/freetype and
# x11-libs/libXScrnSaver are not directly linked (no NEEDED entry found) but
# are declared by Cisco's own (unused on this code path) embedded .deb control
# metadata for a "normal .deb" install; kept here defensively since Qt/WebEngine
# can dlopen platform integration backends that would otherwise fail silently.
RDEPEND="
	app-arch/brotli
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd[X]
	media-libs/libpng:0
	media-libs/libpulse
	sys-apps/dbus
	elibc_glibc? ( sys-libs/glibc )
	virtual/udev
	virtual/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/libxkbfile
"

QA_PREBUILT="opt/pt/*"

pkg_nofetch() {
	ewarn "To fetch sources, you need a Cisco account which is"
	ewarn "available if you're a web-learning student, instructor"
	ewarn "or you sale Cisco hardware, etc."
	ewarn "after that, go to https://www.netacad.com/resources/lab-downloads and login with"
	ewarn "your account, and after that, you should download a file"
	ewarn "named \"${A}\" then move it to"
	ewarn "your DISTDIR directory"
	ewarn "and then, you can proceed with the installation."
}

src_unpack() {
	# Unpacks the outer .deb (control.tar.* + data.tar.*) via unpacker.eclass.
	default

	# The .deb only contains opt/pt/packettracer.AppImage; extract its
	# squashfs payload to get a normal installable tree (icons, .desktop
	# files, the app itself, and its bundled compat libs).
	"${WORKDIR}"/opt/pt/packettracer.AppImage --appimage-extract ||
		die "Failed to extract packettracer.AppImage"
}

src_install() {
	cd "${WORKDIR}"/squashfs-root || die

	# Cisco's own opt/pt/{bin,plugins,translations,...} tree, installed
	# verbatim so its internal relative layout and executable bits survive
	# (doins would strip the executable bit from the many binaries in here).
	cp -r opt "${ED}"/ || die

	# ABI-compat shim libraries bundled by upstream for SONAMEs current
	# distros no longer ship (e.g. libtiff.so.5); kept isolated under
	# /opt/pt so only this package's own launcher picks them up.
	insinto /opt/pt/compat-lib
	doins usr/lib/*.so*

	insinto /usr/share/mime/packages
	doins usr/share/mime/packages/*.xml

	newicon -s 48 app.png packettracer.png
	for m in pka pkt pkz pks pksz; do
		newicon -s 48 -c mimetypes \
			usr/share/icons/gnome/48x48/mimetypes/${m}.png application-x-${m}.png
	done

	newmenu "${FILESDIR}"/${PN}-${PV}.desktop ${PN}.desktop
	newmenu "${FILESDIR}"/${PN}-${PV}-ptsa.desktop ${PN}-ptsa.desktop

	exeinto /opt/pt
	newexe "${FILESDIR}"/${PN}-launcher.sh packettracer
	dosym -r /opt/pt/packettracer /usr/bin/packettracer

	fperms +x /opt/pt/bin/PacketTracer /opt/pt/bin/updatepttp
}
