# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop readme.gentoo-r1 systemd unpacker xdg

DESCRIPTION="Official AWS Client VPN GUI, CLI, and background daemon"
HOMEPAGE="https://docs.aws.amazon.com/vpn/latest/clientvpn-user/client-vpn-connect-linux.html"
SRC_URI="https://d20adtppz83p9s.cloudfront.net/GTK/${PV}/${PN}_amd64.deb"
S="${WORKDIR}"

# Proprietary AWS-distributed binary; upstream publishes amd64-only Ubuntu
# LTS .deb packages, no arm64 build exists, so ~arm64 is omitted rather
# than fabricated. This conflicts with this overlay's policy requiring
# ~amd64 ~arm64 on every new ebuild. The repository owner must explicitly
# accept an exception for this package or exclude it from the overlay.
#
# Separately, this binary is glibc-linked (see RDEPEND) and has no musl
# build; it is therefore also unresolvable on musl profiles, which is
# already the correct, explicit way to express that constraint in Portage
# (RDEPEND=sys-libs/glibc makes the package correctly unsolvable there
# rather than silently broken) -- `pkgcheck scan` reports this as an
# expected NonsolvableDepsInDev finding against the musl dev profile
# group, not an ebuild defect.
#
# The AWS daemon/GUI themselves are all-rights-reserved. Every one of the
# 352 bundled third-party components (mostly Rust crates backing the
# Electron/Node GUI and the Rust aws-client-vpn-daemon) listed in
# THIRD-PARTY-LICENSES.txt was programmatically classified by matching
# each component's actual attached license text (grouping consecutive
# entries that share one license block, as the file itself does), not by
# keyword-sampling the file:
#   Apache-2.0: 227, MIT: 88, Unicode-3.0: 21 (icu4x family; text shares
#   MIT-style wording but is a distinct SPDX license), BSD-3-Clause (->
#   BSD): 3, ISC: 5, MPL-2.0: 1 standalone + 1 more as part of the
#   OpenVPN3 dual-license below, BlueOak-1.0.0: 1 (minicbor),
#   CDLA-Permissive-2.0: 1 (webpki-roots), ZLIB: 2 (foldhash, nanorand).
# IMPORTANT CORRECTION vs. an earlier, less rigorous pass of this audit:
# the bundled OpenVPN3 (the actual VPN protocol implementation, version
# 3.11.5) is dual-licensed AGPL-3.0-only OR MPL-2.0 (redistributor's
# choice), with a special exception permitting linking against OpenSSL
# under the AGPL branch. This was missed by an earlier keyword-only
# sampling pass over this same file and is the most legally significant
# finding here -- expressed below as || ( AGPL-3 MPL-2.0 ), which is
# already satisfied by the unconditional MPL-2.0 entry above it.
LICENSE="all-rights-reserved Apache-2.0 MIT Unicode-3.0 BSD ISC MPL-2.0
	BlueOak-1.0.0 CDLA-Permissive-2.0 ZLIB || ( AGPL-3 MPL-2.0 )"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

# Every direct RDEPEND below was derived from `readelf -d` NEEDED entries
# across every installed ELF object (the GUI, CLI, daemon, chrome-sandbox,
# chrome_crashpad_handler, the bundled Chromium/Vulkan/EGL/ffmpeg .so
# files, and the daemon-client.node addon), not just the .deb's own
# Depends: line, which under-declares several directly-linked libraries
# (atk, atk-bridge/at-spi2, cairo, cups, dbus, expat, glib, nspr, pango,
# udev, and most of the individual X11 libs). libnotify, libXScrnSaver and
# libXtst are NOT in any NEEDED entry (Chromium dlopen()s them at runtime)
# but are kept since the .deb's Depends: explicitly declares them.
# libssl.so/libcrypto.so/libffmpeg.so/libEGL.so/libGLESv2.so/
# libvk_swiftshader.so/libvulkan.so.1 are bundled by the package itself
# (resolved via $ORIGIN rpath/runpath) and are not external RDEPEND.
# glibc is a hard runtime requirement (see musl note below); libstdc++ is
# provided by the base toolchain and is not separately declared, per tree
# convention for other prebuilt-binary packages.
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
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
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
"

QA_PREBUILT="opt/awsvpnclient/*"

DOC_CONTENTS="
This installs aws-client-vpn-daemon as a systemd service that must run
as root to manage VPN routing and DNS. It is NOT started or enabled
automatically; run 'systemctl enable --now aws-client-vpn-daemon' to
start it.

The bundled chrome-sandbox helper is installed non-executable and unused,
matching upstream: the GUI is launched with --no-sandbox.
"

src_install() {
	local basedir="/opt/awsvpnclient"

	# Ground truth verified directly against the .deb's data.tar.gz member
	# permissions (cross-checked with both Python's tarfile and GNU tar):
	# only "AWS VPN Client" and launch-vpn-client.sh ship executable.
	# Debian's postinst maintainer script (which Portage does not run)
	# separately chmods aws-client-vpn-daemon (750), aws-vpn-client (755)
	# and dns/configure-dns (750) at install time -- replicated below via
	# newexe/fperms. Everything else, INCLUDING chrome_crashpad_handler,
	# chrome-sandbox, every bundled .so, and all of locales/ and
	# resources/ (including the daemon-client.node native addon), ships
	# and stays non-executable even after a real upstream install.
	exeinto "${basedir}"
	doexe "opt/awsvpnclient/AWS VPN Client"
	doexe opt/awsvpnclient/launch-vpn-client.sh
	newexe opt/awsvpnclient/aws-vpn-client aws-vpn-client
	newexe opt/awsvpnclient/aws-client-vpn-daemon aws-client-vpn-daemon
	# root-only: only meant to be invoked by the systemd service below
	fperms 750 "${basedir}/aws-client-vpn-daemon"

	exeinto "${basedir}/dns"
	newexe opt/awsvpnclient/dns/configure-dns configure-dns
	fperms 750 "${basedir}/dns/configure-dns"

	insinto "${basedir}"
	insopts -m0644
	doins opt/awsvpnclient/*.so* opt/awsvpnclient/*.pak opt/awsvpnclient/*.bin \
		opt/awsvpnclient/*.dat opt/awsvpnclient/*.json opt/awsvpnclient/version \
		opt/awsvpnclient/app_version opt/awsvpnclient/chrome_crashpad_handler
	# unused (GUI runs with --no-sandbox); shipped inert like upstream
	doins opt/awsvpnclient/chrome-sandbox
	doins -r opt/awsvpnclient/locales opt/awsvpnclient/resources

	dosym "${basedir}/aws-vpn-client" /usr/bin/aws-vpn-client

	newicon opt/awsvpnclient/resources/app.png awsvpnclient.png
	make_desktop_entry "${basedir}/launch-vpn-client.sh" "AWS VPN Client" \
		awsvpnclient "Network;VPN;"

	systemd_dounit etc/systemd/system/aws-client-vpn-daemon.service

	# runtime state dir for the root-run daemon; owner/mode match upstream's
	# postinst maintainer script (mkdir -p + chmod 700)
	keepdir /var/lib/awsvpnclient
	fowners root:root /var/lib/awsvpnclient
	fperms 700 /var/lib/awsvpnclient

	dodoc opt/awsvpnclient/LICENSE opt/awsvpnclient/THIRD-PARTY-LICENSES.txt
	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	readme.gentoo_print_elog
}

pkg_prerm() {
	xdg_pkg_prerm
}
