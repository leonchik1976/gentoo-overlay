# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PLOCALES="de en es fr id ja ko pt pt_BR tr zh zh_CN"
PLOCALE_BACKUP="en"

inherit edo gnome2-utils pax-utils plocale unpacker xdg

DESCRIPTION="Amazon WorkSpaces Client"
HOMEPAGE="https://clients.amazonworkspaces.com"
SRC_URI="https://d3nt0h4h6pmmc4.cloudfront.net/new_workspacesclient_noble_amd64.deb
	-> workspacesclient-${PV}_amd64.deb"
S="${WORKDIR}"

# The DCV viewer component bundles a private copy of Chromium Embedded
# Framework (CEF); amazon-workspaces-bin ships no source for either the
# client itself or the CEF build it vendors.
LICENSE="all-rights-reserved Apache-2.0 GPL-2 MIT no-source-code"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# usr/bin/workspacesclient is launched directly by the desktop entry and
# resolves these sonames from the system library path.
RDEPEND="app-accessibility/at-spi2-core:2
	app-arch/bzip2:0=
	dev-libs/glib:2
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3"
# The DCV viewer subprocess (dcvviewer) and its embedded CEF browser are
# launched via the bundled usr/lib/x86_64-linux-gnu/workspacesclient/
# workspacesclientdcv wrapper script, which points LD_LIBRARY_PATH,
# GST_PLUGIN_SYSTEM_PATH, GIO_EXTRA_MODULES, and GDK_PIXBUF_MODULE_FILE at
# the private lib bundle installed alongside it and at usr/share/
# workspacesclient/cef. Nearly everything a private lib or CEF itself
# needs is satisfied from within that same bundle; the packages below are
# only the sonames that are genuinely absent from both directories and so
# must come from the system, as verified by inspecting the DT_NEEDED
# entries of every ELF object in the .deb against the files it ships.
RDEPEND+="
	app-arch/brotli:0=
	app-arch/libdeflate:0=
	app-arch/xz-utils
	app-arch/zstd
	dev-db/sqlite:3
	dev-libs/elfutils
	dev-libs/libgudev
	dev-libs/libxml2-compat
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0=
	gnome-base/dconf
	media-libs/alsa-lib
	media-libs/gst-plugins-base:1.0
	media-libs/jbigkit
	media-libs/lerc
	media-libs/libpng:0=
	media-libs/libpulse
	media-libs/libva
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/pcsc-lite
	sys-libs/libselinux
	sys-libs/libunwind
	virtual/krb5
	virtual/udev
	x11-libs/libdrm
	x11-libs/libvdpau
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXft
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender"
# Two of the .deb's own Depends are deliberately not carried over as RDEPEND:
#
# - opensc-pkcs11: only used for optional smartcard login (client dlopens a
#   hardcoded "/usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so"). The
#   client is fully functional without it (PG0001), and dev-libs/opensc
#   installs to /usr/lib64/pkcs11/opensc-pkcs11.so on Gentoo anyway, so even
#   emerging it would not satisfy that hardcoded path without an additional
#   manual symlink; see the pkg_postinst elog.
# - sssd/libpam-sss: only relevant for enterprise Kerberos/LDAP domain-join
#   SSO, which requires separately configuring the host's own PAM/NSS
#   stack regardless of this package; forcing sys-auth/sssd on every
#   install for a feature that needs that much extra host configuration
#   anyway is not warranted.
BDEPEND="dev-util/patchelf"

QA_PREBUILT="usr/bin/workspacesclient
	usr/share/workspacesclient/cef/chrome-sandbox
	usr/share/workspacesclient/cef/libEGL.so
	usr/share/workspacesclient/cef/libGLESv2.so
	usr/share/workspacesclient/cef/libcef.so
	usr/share/workspacesclient/cef/libvk_swiftshader.so
	usr/share/workspacesclient/cef/libvulkan.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/dcvextensionswatchdog
	usr/lib/x86_64-linux-gnu/workspacesclient/dcvviewer
	usr/lib/x86_64-linux-gnu/workspacesclient/dcvwebrtcredirextension
	usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-gif.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-jpeg.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-png.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-query-loaders
	usr/lib/x86_64-linux-gnu/workspacesclient/gio/modules/libgiolibproxy.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gio/modules/libgioopenssl.so
	usr/lib/x86_64-linux-gnu/workspacesclient/glib-compile-resources
	usr/lib/x86_64-linux-gnu/workspacesclient/glib-compile-schemas
	usr/lib/x86_64-linux-gnu/workspacesclient/gst-plugin-scanner
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstapp.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstaudioconvert.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstaudioresample.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstcoreelements.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstcutter.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstopus.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstpulseaudio.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstvideo4linux2.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstvideoconvertscale.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstvideorate.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstvpx.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gstreamer-1.0/libgstwebrtcdsp.so
	usr/lib/x86_64-linux-gnu/workspacesclient/gtk4-update-icon-cache
	usr/lib/x86_64-linux-gnu/workspacesclient/libavcodec.so.62
	usr/lib/x86_64-linux-gnu/workspacesclient/libavutil.so.60
	usr/lib/x86_64-linux-gnu/workspacesclient/libcairo-gobject.so.2
	usr/lib/x86_64-linux-gnu/workspacesclient/libcairo-script-interpreter.so.2
	usr/lib/x86_64-linux-gnu/workspacesclient/libcairo.so.2
	usr/lib/x86_64-linux-gnu/workspacesclient/libdav1d.so.7
	usr/lib/x86_64-linux-gnu/workspacesclient/libdcv.so
	usr/lib/x86_64-linux-gnu/workspacesclient/libepoxy.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libexpat.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libffi.so.8
	usr/lib/x86_64-linux-gnu/workspacesclient/libfido2.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libfontconfig.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libfreetype.so.6
	usr/lib/x86_64-linux-gnu/workspacesclient/libfribidi.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgdk_pixbuf-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgio-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libglib-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgmodule-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgobject-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgraphene-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstallocators-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstapp-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstaudio-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstbadaudio-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstbase-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstreamer-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgstvideo-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgthread-2.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libgtk-4.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libharfbuzz-subset.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libharfbuzz.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libjpeg.so.62
	usr/lib/x86_64-linux-gnu/workspacesclient/libjson-glib-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/liblmdb.so
	usr/lib/x86_64-linux-gnu/workspacesclient/liblz4.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libnghttp2.so.14
	usr/lib/x86_64-linux-gnu/workspacesclient/libopus.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/liborc-0.4.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpango-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpangocairo-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpangoft2-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpangoxft-1.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpcre2-8.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libpixman-1.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libprotobuf-c.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libproxy.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libpsl.so.5
	usr/lib/x86_64-linux-gnu/workspacesclient/libpxbackend-1.0.so
	usr/lib/x86_64-linux-gnu/workspacesclient/librsvg-2.so.2
	usr/lib/x86_64-linux-gnu/workspacesclient/libsasl2.so.3
	usr/lib/x86_64-linux-gnu/workspacesclient/libsoup-3.0.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libtiff.so.6
	usr/lib/x86_64-linux-gnu/workspacesclient/libturbojpeg.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libvpx.so.11
	usr/lib/x86_64-linux-gnu/workspacesclient/libwayland-client.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libwayland-cursor.so.0
	usr/lib/x86_64-linux-gnu/workspacesclient/libwayland-egl.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libwebrtc-audio-processing-2.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/libz.so.1
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libanonymous.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libcrammd5.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libdigestmd5.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libgs2.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libgssapiv2.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libotp.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libplain.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libsasldb.so
	usr/lib/x86_64-linux-gnu/workspacesclient/sasl2/libscram.so"

src_prepare() {
	default

	my_rm_loc() {
		rm -rf usr/share/locale/"${1}" || die "rm failed for ${1}"
	}
	plocale_for_each_disabled_locale my_rm_loc

	edo rm -rf usr/share/doc

	# The bundled harfbuzz-icu was built against Ubuntu's ICU 74. ICU does
	# not preserve ABI across major versions (symbols are suffixed with the
	# version, e.g. ucol_strcoll_74), so retargeting its NEEDED entry at
	# dev-libs/icu's SONAME (78) would produce a library that fails with
	# undefined-symbol errors the moment anything actually loads it -- not
	# an ABI-correct fix. readelf -d across every ELF object in the .deb
	# shows no NEEDED entry for libharfbuzz-icu.so.0 (link-time), and no
	# file in the .deb contains the string "harfbuzz-icu" other than the
	# library's own embedded SONAME (ruling out a dlopen()-by-name call
	# too), so it is unused; drop it instead of shipping a library that
	# would break if anything ever did load it.
	edo rm -f usr/lib/x86_64-linux-gnu/workspacesclient/libharfbuzz-icu.so.0

	# x11-libs/pango disables libthai
	edo patchelf --remove-needed libthai.so.0 usr/lib/x86_64-linux-gnu/workspacesclient/libpango-1.0.so.0
}

src_install() {
	insinto /
	doins -r .
	fperms +x /usr/bin/workspacesclient \
		/usr/lib/x86_64-linux-gnu/workspacesclient/dcvextensionswatchdog \
		/usr/lib/x86_64-linux-gnu/workspacesclient/dcvviewer \
		/usr/lib/x86_64-linux-gnu/workspacesclient/dcvwebrtcredirextension \
		/usr/lib/x86_64-linux-gnu/workspacesclient/gdk-pixbuf-query-loaders \
		/usr/lib/x86_64-linux-gnu/workspacesclient/glib-compile-resources \
		/usr/lib/x86_64-linux-gnu/workspacesclient/glib-compile-schemas \
		/usr/lib/x86_64-linux-gnu/workspacesclient/gst-plugin-scanner \
		/usr/lib/x86_64-linux-gnu/workspacesclient/gtk4-update-icon-cache \
		/usr/lib/x86_64-linux-gnu/workspacesclient/workspacesclientdcv

	dosym ../lib/x86_64-linux-gnu/workspacesclient/workspacesclientdcv \
		/usr/bin/workspacesclientdcv

	# Upstream ships this setuid root (rwsr-xr-x) as CEF's SUID sandbox
	# helper, used to enable process sandboxing on kernels/configurations
	# where unprivileged user namespaces are unavailable; doins strips
	# that bit, so it must be restored explicitly.
	fperms 4755 /usr/share/workspacesclient/cef/chrome-sandbox

	# Upstream's own postinst symlinks the system dconf GIO module into
	# its private GIO_EXTRA_MODULES dir ("Hack in order to have dconf
	# working"); without it GSettings falls back to a non-persistent
	# backend and the app's own settings are lost on exit. Replicate it.
	dosym ../../../../../lib64/gio/modules/libdconfsettings.so \
		/usr/lib/x86_64-linux-gnu/workspacesclient/gio/modules/libdconfsettings.so

	pax-mark -m "${ED}"/usr/bin/workspacesclient \
		"${ED}"/usr/lib/x86_64-linux-gnu/workspacesclient/dcvviewer
}

pkg_preinst() {
	gnome2_gdk_pixbuf_savelist
	xdg_pkg_preinst
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_pkg_postinst

	elog "Smartcard login is optional and not pulled in by default."
	elog "It needs dev-libs/opensc, and the client looks for its PKCS#11"
	elog "module at the Debian multiarch path"
	elog "  /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so"
	elog "which dev-libs/opensc does not provide on Gentoo (it installs to"
	elog "/usr/lib64/pkcs11/opensc-pkcs11.so instead), so a manual symlink"
	elog "is required in addition to emerging dev-libs/opensc:"
	elog "  mkdir -p /usr/lib/x86_64-linux-gnu/pkcs11"
	elog "  ln -s /usr/lib64/pkcs11/opensc-pkcs11.so \\"
	elog "        /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so"
	elog "Enterprise Kerberos/LDAP SSO via sys-auth/sssd likewise needs its"
	elog "own separate PAM/NSS configuration on this host and is out of"
	elog "scope for this ebuild."
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_pkg_postrm
}
