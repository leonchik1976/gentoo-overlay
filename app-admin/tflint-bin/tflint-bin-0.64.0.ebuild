# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Pluggable Terraform linter"
HOMEPAGE="
	https://github.com/terraform-linters/tflint
"
SRC_URI="
	amd64? (
		https://github.com/terraform-linters/${PN%-bin}/releases/download/v${PV}/${PN%-bin}_linux_amd64.zip
			-> ${P}-amd64.zip
	)
	arm64? (
		https://github.com/terraform-linters/${PN%-bin}/releases/download/v${PV}/${PN%-bin}_linux_arm64.zip
			-> ${P}-arm64.zip
	)
"
S="${WORKDIR}"

LICENSE="MPL-2.0 BUSL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

BDEPEND="app-arch/unzip"
RDEPEND="!app-admin/tflint"

QA_PREBUILT="usr/bin/tflint"

src_install() {
	newbin tflint tflint
}
