# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="MinIO AIStor command-line client for S3-compatible object storage"
HOMEPAGE="https://www.min.io/download/aistor-client"
MY_RELEASE="RELEASE.2026-09-19T15-24-59Z"
SRC_URI="
	amd64? ( https://dl.min.io/aistor/mc/release/linux-amd64/archive/mc.${MY_RELEASE} -> ${P}-amd64 )
	arm64? ( https://dl.min.io/aistor/mc/release/linux-arm64/archive/mc.${MY_RELEASE} -> ${P}-arm64 )
"
S="${WORKDIR}"

LICENSE="MinIO-Software-License"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# The proprietary client license does not grant redistribution rights.
# Preserve the upstream executable without stripping or other modification.
RESTRICT="bindist mirror strip"
QA_PREBUILT="usr/bin/mcli"

src_unpack() {
	local arch
	if use amd64; then
		arch=amd64
	elif use arm64; then
		arch=arm64
	else
		die "Unsupported architecture"
	fi
	cp "${DISTDIR}/${P}-${arch}" mcli || die
}

src_install() {
	dobin mcli
}

# Unresolved upstream licensing discrepancy:
# https://www.min.io/download/aistor-client publishes one-instance evaluation
# terms without an enterprise agreement, while Free deployment instructions at
# https://docs.min.io/aistor/installation/windows/install/ direct users to this
# client. Those instructions do not explicitly extend the server's AIStor Free
# Agreement to the client; upstream clarification is still needed.
pkg_postinst() {
	elog "The AIStor Client is installed as mcli; substitute mcli for mc in upstream examples."
	elog "The client has a separate MinIO Software License, not the AIStor Free Agreement."
	elog "Without an enterprise agreement, its license permits only one instance"
	elog "for internal, non-production evaluation."
}
