# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Command-line interface for running and interacting with Temporal"
HOMEPAGE="https://temporal.io https://github.com/temporalio/cli"
SRC_URI="
	amd64? (
		https://github.com/temporalio/cli/releases/download/v${PV}/temporal_cli_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/temporalio/cli/releases/download/v${PV}/temporal_cli_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 imagemagick"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip"
QA_PREBUILT="usr/bin/temporal"

src_install() {
	dobin temporal
	dodoc LICENSE

	newbashcomp "${FILESDIR}/temporal-${PV}.bash" temporal
	newzshcomp "${FILESDIR}/temporal-${PV}.zsh" _temporal
	newfishcomp "${FILESDIR}/temporal-${PV}.fish" temporal.fish
}
