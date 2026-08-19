# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Download and manage MuseSounds playback expansions for MuseScore Studio"
HOMEPAGE="
	https://musescore.org/en/handbook/4/installing-muse-sounds
	https://www.musehub.com/muse-sounds
"
# The vendor's CDN URL always serves the latest release regardless of
# filename, so it cannot be pinned to this ebuild's exact version for
# automatic, integrity-checked fetching.
SRC_URI="amd64? ( https://muse-cdn.com/Muse_Sounds_Manager_x64.deb -> ${P}-amd64.deb )"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
# Local overlay keyword policy defaults new ebuilds to ~amd64 ~arm64; this is
# a documented exception, not an oversight. MuseGroup only publishes
# Muse_Sounds_Manager_x64.deb; no arm64 Linux build exists (their macOS
# build covers Apple Silicon, but the Linux build is x86_64-only).
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="fetch mirror strip"

RDEPEND="
	elibc_glibc? ( sys-libs/glibc )
	media-libs/fontconfig
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
"

QA_PREBUILT="opt/muse-sounds-manager/*"

pkg_nofetch() {
	ewarn "Muse Sounds Manager's CDN URL always serves the latest release"
	ewarn "regardless of filename, so it cannot be fetched automatically"
	ewarn "against a pinned version."
	ewarn
	ewarn "To fetch the distfile(s):"
	ewarn " 1. Visit https://www.musehub.com/muse-sounds and download the"
	ewarn "    Linux .deb."
	ewarn " 2. Save it as ${P}-amd64.deb in your DISTDIR directory."
	ewarn " 3. Re-run emerge."
	ewarn
	ewarn "If the site now serves a version newer than ${PV}, this ebuild's"
	ewarn "Manifest will reject it -- check for a newer ebuild version first."
}

src_prepare() {
	default

	sed -i \
		-e '/^Encoding=/d' \
		-e 's/^Categories=.*/Categories=GNOME;Network;/' \
		usr/share/applications/muse-sounds-manager.desktop ||
		die "failed to fix desktop entry"
}

src_install() {
	insinto /opt/muse-sounds-manager
	doins opt/muse-sounds-manager/lib*.so

	exeinto /opt/muse-sounds-manager
	doexe opt/muse-sounds-manager/muse-sounds-manager

	dosym ../../opt/muse-sounds-manager/muse-sounds-manager \
		/usr/bin/muse-sounds-manager

	local size
	for size in 48 64 128 256; do
		doicon -s ${size} \
			usr/share/icons/hicolor/${size}x${size}/apps/muse-sounds-manager.png
	done
	domenu usr/share/applications/muse-sounds-manager.desktop
}
