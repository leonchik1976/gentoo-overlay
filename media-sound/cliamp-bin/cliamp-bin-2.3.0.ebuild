# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# xdg.eclass does not yet support EAPI 9.
EAPI=8

inherit desktop optfeature xdg

DESCRIPTION="Terminal music player inspired by Winamp (upstream binary)"
HOMEPAGE="https://www.cliamp.stream https://github.com/bjarneo/cliamp"
SRC_URI="
	amd64? ( https://github.com/bjarneo/cliamp/releases/download/v${PV}/cliamp-linux-amd64 -> ${P}-amd64 )
	arm64? ( https://github.com/bjarneo/cliamp/releases/download/v${PV}/cliamp-linux-arm64 -> ${P}-arm64 )
	https://github.com/bjarneo/cliamp/archive/refs/tags/v${PV}.tar.gz -> cliamp-${PV}.tar.gz
"
S="${WORKDIR}/cliamp-${PV}"

# Includes Go modules and statically linked codec libraries. vorbis-go has
# an all-rights-reserved generated header and no clear license grant.
# Unmasked for personal use; the unresolved grant is documented in review notes.
LICENSE="MIT Apache-2.0 BSD BSD-2 ISC GPL-3 Unlicense LGPL-2.1 all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	media-libs/alsa-lib
	>=sys-libs/glibc-2.34
"

QA_PREBUILT="usr/bin/cliamp"

src_unpack() {
	unpack "cliamp-${PV}.tar.gz"
}

src_compile() {
	# The source archive is used only for documentation and desktop assets.
	:
}

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" cliamp
	domenu cliamp.desktop
	newicon -s 512 Cliamp.png cliamp.png
	dodoc README.md
	dodoc -r docs
	dodoc LICENSE
	# The index maps component filenames to verbatim SHA256 objects.
	local kind
	for kind in go codec; do
		(
			mkdir -p "${T}/third-party-notices/${kind}" || die
			cd "${T}/third-party-notices/${kind}" || die
			unpack "${FILESDIR}/cliamp-${PV}-${kind}-notices.tar.xz"
		) || die "Failed to unpack ${kind} notices"
	done
	dodoc -r "${T}/third-party-notices"
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "additional audio formats and streaming pipelines" media-video/ffmpeg
	optfeature "online media extraction" net-misc/yt-dlp
	elog "Configure your ALSA default device for your audio setup."
	elog "For PulseAudio routing, media-plugins/alsa-plugins[pulseaudio] provides the ALSA plugin."
}
