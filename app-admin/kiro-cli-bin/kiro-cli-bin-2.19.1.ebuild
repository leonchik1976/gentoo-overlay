# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Command line interface for the Kiro AI-powered IDE/agent"
HOMEPAGE="
	https://kiro.dev/
	https://kiro.dev/cli/
"
SRC_URI="
	amd64? (
		https://prod.download.cli.kiro.dev/stable/${PV}/kirocli-x86_64-linux.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://prod.download.cli.kiro.dev/stable/${PV}/kirocli-aarch64-linux.tar.gz
			-> ${P}-arm64.tar.gz
	)
"

S="${WORKDIR}/kirocli"

# Proprietary: licensed as "AWS Content" under the AWS Customer Agreement and
# the AWS Intellectual Property License (https://kiro.dev/license/). No
# specific Gentoo license entry exists for this; the download URLs are plain
# public HTTPS URLs requiring no authentication, but redistribution/mirroring
# rights are not granted.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="elibc_glibc? ( sys-libs/glibc )"

QA_PREBUILT="usr/bin/kiro-cli*"

src_install() {
	dobin bin/kiro-cli bin/kiro-cli-chat bin/kiro-cli-term
	dodoc README BUILD-INFO
}
