# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Declarative database schema management (proprietary MSA build, prebuilt binary)"
HOMEPAGE="https://atlasgo.io/"
SRC_URI="
	amd64? (
		!extended? ( https://release.ariga.io/atlas/atlas-linux-amd64-v${PV} -> ${P}-amd64.bin )
		extended? ( https://release.ariga.io/atlas/atlas-linux-amd64-extended-v${PV} -> ${P}-amd64-extended.bin )
	)
	arm64? (
		!extended? ( https://release.ariga.io/atlas/atlas-linux-arm64-v${PV} -> ${P}-arm64.bin )
		extended? ( https://release.ariga.io/atlas/atlas-linux-arm64-extended-v${PV} -> ${P}-arm64-extended.bin )
	)
"
S="${WORKDIR}"

# Ariga distributes this build under their Master License and Services
# Agreement (formerly called the "Atlas EULA"); it is proprietary and
# layered on top of the Apache-2.0 ariga/atlas open source project that
# dev-db/atlas-bin installs a prebuilt Community Edition binary of. See
# licenses/Atlas-MSA-20260701.
LICENSE="Atlas-MSA-20260701"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="extended"
RESTRICT="mirror strip bindist"

# Installs as /usr/bin/atlas, same path as dev-db/atlas-bin; the two are
# alternative builds of the same CLI and are not meant to coexist.
RDEPEND="!dev-db/atlas-bin"

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
	local suffix="${ARCH}"
	use extended && suffix+="-extended"

	newbin "${P}-${suffix}.bin" atlas
}
