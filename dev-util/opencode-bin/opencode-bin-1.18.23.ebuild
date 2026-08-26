# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="The open source coding agent"
HOMEPAGE="https://opencode.ai"
SRC_URI="
	amd64? (
		elibc_glibc? (
			https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-x64-baseline.tar.gz
				-> ${P}-amd64-glibc.tar.gz
		)
		elibc_musl? (
			https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-x64-baseline-musl.tar.gz
				-> ${P}-amd64-musl.tar.gz
		)
	)
	arm64? (
		elibc_glibc? (
			https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-arm64.tar.gz
				-> ${P}-arm64-glibc.tar.gz
		)
		elibc_musl? (
			https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-arm64-musl.tar.gz
				-> ${P}-arm64-musl.tar.gz
		)
	)
"
S=${WORKDIR}

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="^^ ( elibc_glibc elibc_musl )"
RESTRICT="mirror strip"

RDEPEND="
	elibc_glibc? ( >=sys-libs/glibc-2.17 )
	elibc_musl? (
		sys-devel/gcc:*
		sys-libs/musl
	)
"

QA_PREBUILT="usr/bin/opencode"

src_install() {
	dobin opencode

	newenvd - 50opencode <<-EOF
		OPENCODE_DISABLE_AUTOUPDATE=1
	EOF
}
