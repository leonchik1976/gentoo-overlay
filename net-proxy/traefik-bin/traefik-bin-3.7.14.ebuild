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

# Main license and exact embedded Go-module notices were audited.
# The large FILESDIR notice bundle is an intentional personal-overlay exception;
# see scripts/README.traefik-notices.md. Size QA findings remain visible.
LICENSE="MIT Apache-2.0 BSD ISC MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

ACCT_DEPEND="
	acct-group/traefik
	acct-user/traefik
"
RDEPEND="${ACCT_DEPEND}"
BDEPEND+=" app-arch/xz-utils"

QA_PREBUILT="usr/bin/traefik"

src_install() {
	dobin traefik
	dodoc CHANGELOG.md LICENSE.md
	local notices="${T}/third-party-notices"
	mkdir -p "${notices}" || die
	tar -xJf "${FILESDIR}/${P}-third-party-notices.tar.xz" -C "${notices}" || die
	docinto third-party-notices
	dodoc -r "${notices}/."
	docinto /

	insinto /etc/traefik
	doins "${FILESDIR}"/traefik.yaml
	keepdir /etc/traefik/dynamic

	systemd_newunit "${FILESDIR}"/traefik.service traefik.service

	keepdir /var/lib/traefik
	fowners traefik:traefik /var/lib/traefik
}
