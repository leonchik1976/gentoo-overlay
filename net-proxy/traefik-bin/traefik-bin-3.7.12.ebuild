# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN=${PN%-bin}
MY_PV=${PV}

DESCRIPTION="Modern HTTP reverse proxy and load balancer"
HOMEPAGE="https://traefik.io/traefik/ https://github.com/traefik/traefik"
SRC_URI="
	amd64? (
		https://github.com/traefik/traefik/releases/download/v${MY_PV}/${MY_PN}_v${MY_PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/traefik/traefik/releases/download/v${MY_PV}/${MY_PN}_v${MY_PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

# The official release archive ships only the MIT LICENSE.md; the
# web dashboard's own third-party JS licenses are not separately
# vendored in this archive.
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

ACCT_DEPEND="
	acct-group/traefik
	acct-user/traefik
"
RDEPEND="${ACCT_DEPEND}"

QA_PREBUILT="usr/bin/traefik"

src_install() {
	dobin traefik
	dodoc CHANGELOG.md

	insinto /etc/traefik
	doins "${FILESDIR}"/traefik.yaml
	keepdir /etc/traefik/dynamic

	systemd_newunit "${FILESDIR}"/traefik.service traefik.service

	keepdir /var/lib/traefik
	fowners traefik:traefik /var/lib/traefik
}
