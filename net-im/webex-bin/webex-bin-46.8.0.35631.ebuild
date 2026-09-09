# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# unpacker.eclass, xdg.eclass, linux-info.eclass and pax-utils.eclass only
# support EAPI 7/8 in this tree (each guards with `case ${EAPI} in 7|8)
# ... *) die`), so EAPI=9 is not yet available for a .deb-unpacking ebuild.

inherit desktop linux-info optfeature pax-utils unpacker xdg

MY_PN="webex"

DESCRIPTION="Cisco Webex meetings, messaging and calling client"
HOMEPAGE="https://www.webex.com/"
# Cisco publishes only a single, unversioned "latest" URL per OS on
# binaries.webex.com -- there is no per-release download path. The Manifest
# hash below pins this exact 46.8.0.35631 build; when Cisco rotates the file
# behind this URL the checksum stops matching and this ebuild must be bumped
# (the previous distfile then becomes unfetchable). RESTRICT=mirror keeps it
# off Gentoo mirrors, so the only source is Cisco's CDN.
#
# The .deb carries an embedded dpkg-sig "builder" signature (its _gpgbuilder
# ar member: an OpenPGP clearsigned manifest of the md5/sha1/size of the
# other members). For 46.8.0.35631 it was verified offline against Cisco's
# key at
#   https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/webex_public.key
#   rsa4096, "Engineering Systems Team <tac.connect@webex.bot>"
#   fpr 4736 6800 E23E B3CC BEED  F952 9995 E5BB B5CC DE3C  (expires 2027-02-24)
# -> "Good signature", data.tar.xz sha1 e111c7fcf1c71e5e855d55b22557151168eddc59.
# It is not wired into the build: verify-sig.eclass expects a detached sig
# over the distfile (not this format), the key ships from the same CDN path
# as the .deb so it is no independent trust anchor, and the manifest's
# digests are only md5/sha1 -- the Manifest entry below is the stronger
# integrity check. On a version bump, re-verify manually against the *same*
# fingerprint and investigate any key rotation before trusting a new build.
SRC_URI="https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb -> ${MY_PN}-${PV}.deb"
S="${WORKDIR}"

# The .deb ships no license file; control's "Section: non-free" and Cisco's
# EULA (https://www.cisco.com/c/en/us/about/legal/cloud-and-software/end_user_license_agreement.html)
# govern use. No redistribution grant, hence RESTRICT="bindist mirror".
LICENSE="all-rights-reserved"
SLOT="0"
# amd64 only: Cisco ships the Webex Linux client exclusively as an x86-64
# .deb/.rpm. There is no arm64 (or any non-amd64) Linux build upstream, so
# the overlay-wide "~amd64 ~arm64" keyword policy cannot be honoured here --
# an arm64 keyword would be unusable. Reporting the conflict rather than
# fabricating the keyword.
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# All dependencies below are DT_NEEDED of the shipped executables or of the
# Cisco/Qt6/CEF libraries they load unconditionally (verified with readelf -d
# against opt/Webex/{bin,lib} of the 46.8.0.35631 payload). The client bundles
# its own Qt 6, CEF, ICU, libcurl, hunspell, sqlite and heimdal; those are
# intentionally absent here. Its bundled OpenSSL 3 is stripped in src_install
# (it collides with the newer system libssl.so.3 that system libcups.so.2
# drags in), so dev-libs/openssl:0/3 is required. FFmpeg is *not* bundled --
# see src_install. Genuinely optional, dlopen-only integrations (GTK file
# dialogs, VA-API, UPower, speech-dispatcher, OpenCL, xdg-desktop-portal) are
# handled via optfeature in pkg_postinst, per PG0001.
RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/zstd
	app-crypt/libsecret
	app-crypt/mit-krb5
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libgcrypt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa[gbm(+)]
	media-video/ffmpeg-compat:7
	net-libs/libproxy
	net-print/cups
	sys-apps/dbus
	virtual/libcrypt
	virtual/libudev
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/Webex/*"

# Runtime requirement: libcef.so isolates its renderer/GPU processes with an
# unprivileged-user-namespace sandbox, and the .deb ships no setuid
# chrome-sandbox helper to fall back to (nor does this ebuild add one), so
# CONFIG_USER_NS=y is genuinely needed for the client to sandbox itself.
# PID_NS/NET_NS/SECCOMP_FILTER further harden that sandbox when present.
#
# All four are listed with "~" so a missing option only warns instead of
# aborting the merge: check_extra_config cannot see a kernel that builds
# USER_NS but disables it at runtime (kernel.unprivileged_userns_clone=0 or a
# hardened default), the failure mode is a degraded/refused sandbox rather
# than a broken package, and an admin may knowingly accept that. Treat the
# warning as "fix this unless you have made a deliberate choice", not as
# advisory noise.
CONFIG_CHECK="~USER_NS ~PID_NS ~NET_NS ~SECCOMP_FILTER"

src_prepare() {
	default

	local desktop="opt/Webex/bin/${MY_PN}.desktop"

	# - Version= in Cisco's file is the *app* version (46.8.0.35631); in the
	#   Desktop Entry spec that key is the spec version, so drop it rather
	#   than ship an invalid value.
	# - Point Icon= at the theme name we install below instead of an
	#   absolute /opt path.
	# - Comment= just repeats Name=; give it a real description.
	# - "Application" is not a registered menu category and "Utility" is
	#   wrong for a conferencing client; use Network/VideoConference.
	sed -i \
		-e '/^Version=/d' \
		-e 's|^Icon=.*|Icon=webex|' \
		-e 's|^Comment=.*|Comment=Join Webex meetings, message and make calls|' \
		-e 's|^Categories=.*|Categories=Network;VideoConference;|' \
		"${desktop}" || die
}

src_install() {
	dodir /opt
	cp -a opt/Webex "${ED}"/opt/ || die

	# Cisco's bundled libstdc++.so.6 is older than any current system copy and
	# makes the client fail to start when it wins the lookup; its own postinst
	# deactivates it in that case. Always prefer the system library.
	rm "${ED}"/opt/Webex/lib/libstdc++.so.6 || die

	# Drop the bundled OpenSSL 3. Webex's own libraries link libssl.so.3 /
	# libcrypto.so.3 by soname, and system net-print/cups also pulls in the
	# system libssl.so.3; loading both a stale bundled libcrypto.so.3 and the
	# newer system libssl.so.3 into one process fails with "version
	# `OPENSSL_3.x.0' not found". OpenSSL 3.x symbol versioning is additive, so
	# routing every consumer through the (newer) system dev-libs/openssl:0/3 is
	# safe.
	rm "${ED}"/opt/Webex/lib/lib{ssl,crypto}.so{,.3} || die

	# FFmpeg is a hard DT_NEEDED of the Qt Multimedia backend
	# (lib/plugins/multimedia/libffmpegmediaplugin.so: libavcodec.so.61,
	# libavformat.so.61, libavutil.so.59, libswresample.so.5, libswscale.so.8
	# -> FFmpeg 7.x sonames) and Cisco expects the distro to provide it.
	# media-video/ffmpeg-compat:7 installs a slotted copy under
	# /usr/lib/ffmpeg7 that stays at these sonames regardless of the system's
	# main media-video/ffmpeg; symlink it into the client's private libdir
	# (which is on its RUNPATH as $ORIGIN/../lib).
	local ffdir="/usr/lib/ffmpeg7/$(get_libdir)" lib
	for lib in libavcodec.so.61 libavformat.so.61 libavutil.so.59 \
		libswresample.so.5 libswscale.so.8 ; do
		dosym -r "${ffdir}/${lib}" "/opt/Webex/lib/${lib}"
	done

	dosym -r /opt/Webex/bin/CiscoCollabHost /usr/bin/webex

	# libcef.so / V8 need writable-then-executable mappings.
	pax-mark -m "${ED}"/opt/Webex/bin/CiscoCollabHost \
		"${ED}"/opt/Webex/bin/CiscoCollabHostCef

	domenu opt/Webex/bin/"${MY_PN}".desktop
	newicon opt/Webex/bin/sparklogosmall.png webex.png
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "Wayland screen sharing, portal file/camera access" \
		"sys-apps/xdg-desktop-portal sys-apps/xdg-desktop-portal-gtk"
	optfeature "native GTK file-chooser dialogs and GTK theme integration" \
		x11-libs/gtk+:3
	optfeature "hardware-accelerated video decoding (VA-API)" media-libs/libva
	optfeature "GPU-accelerated video effects / virtual background" virtual/opencl
	optfeature "battery/power-state awareness" sys-power/upower
	optfeature "GPU enumeration for the CEF GPU process" sys-apps/pciutils
	optfeature "screen-reader / text-to-speech accessibility" \
		app-accessibility/speech-dispatcher

	elog
	elog "USB call-control for Webex-certified headsets uses raw HID access."
	elog "Cisco's udev rules ship at /opt/Webex/bin/accessories/ but rely on a"
	elog "'plugdev' group and world-writable device nodes; review and adapt"
	elog "them before installing to /etc/udev/rules.d if you need that."
	elog "The EPOS/Sennheiser (DSEA) headset plugin additionally needs"
	elog "libcrypto.so.1.1, which Gentoo no longer provides, so that specific"
	elog "plugin will not load; other headset brands are unaffected."
}

pkg_postrm() {
	xdg_pkg_postrm
}
