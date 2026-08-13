# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Vulnerability scanner for container images, file systems, and Git repos"
HOMEPAGE="https://aquasecurity.github.io/trivy"
SRC_URI="
	amd64? (
		https://github.com/aquasecurity/${PN}/releases/download/v${PV}/${PN}_${PV}_Linux-64bit.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/aquasecurity/${PN}/releases/download/v${PV}/${PN}_${PV}_Linux-ARM64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/bin/trivy"

src_install() {
	dobin trivy
	dodoc README.md

	insinto /usr/share/${PN}/templates
	doins contrib/*.tpl
}
