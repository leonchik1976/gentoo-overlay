# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Thin wrapper for OpenTofu and Terraform"
HOMEPAGE="
	https://terragrunt.gruntwork.io/
	https://github.com/gruntwork-io/terragrunt
"
SRC_URI="
	amd64? (
		https://github.com/gruntwork-io/${PN%-bin}/releases/download/v${PV}/terragrunt_linux_amd64
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/gruntwork-io/${PN%-bin}/releases/download/v${PV}/terragrunt_linux_arm64
			-> ${P}-arm64
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 imagemagick MIT MPL-2.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/terragrunt"

src_unpack() {
	:
}

src_install() {
	local source

	case ${ARCH} in
		amd64)
			source="${DISTDIR}/${P}-amd64"
			;;
		arm64)
			source="${DISTDIR}/${P}-arm64"
			;;
		*)
			die "Unsupported architecture: ${ARCH}"
			;;
	esac

	newbin "${source}" terragrunt
}
