# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Declarative database schema management (community edition, prebuilt binary)"
HOMEPAGE="https://atlasgo.io/"
SRC_URI="
	amd64? ( https://release.ariga.io/atlas/atlas-community-linux-amd64-v${PV} -> ${P}-amd64.bin )
	arm64? ( https://release.ariga.io/atlas/atlas-community-linux-arm64-v${PV} -> ${P}-arm64.bin )
"
S="${WORKDIR}"

# Ariga's officially distributed prebuilt Community Edition binary, built
# from the same public ariga/atlas GitHub repository under the same
# Apache-2.0 license.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

# Installs as /usr/bin/atlas, same path as dev-db/atlas-msa-bin; the two
# are alternative builds of the same CLI and are not meant to coexist.
RDEPEND="!dev-db/atlas-msa-bin"

QA_PREBUILT="usr/bin/atlas"

# The fetched file has no archive extension Portage recognises, so the
# default unpack() silently skips it instead of copying it to ${WORKDIR};
# copy it ourselves.
src_unpack() {
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${WORKDIR}/" || die
	done
}

src_install() {
	newbin "${P}-${ARCH}.bin" atlas
}
