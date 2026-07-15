# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="Security risk analysis for Kubernetes resources"
HOMEPAGE="https://kubesec.io/ https://github.com/controlplaneio/kubesec"
SRC_URI="
	amd64? (
		https://github.com/controlplaneio/${MY_PN}/releases/download/v${PV}/${MY_PN}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/controlplaneio/${MY_PN}/releases/download/v${PV}/${MY_PN}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD MIT MPL-2.0 imagemagick"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/kubesec"

src_install() {
	dobin kubesec
	dodoc CHANGELOG.md README.md
}
