# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="${PN%-bin}"

DESCRIPTION="Cloud cost estimates for Terraform, Terragrunt, and CloudFormation"
HOMEPAGE="https://www.infracost.io https://github.com/infracost/cli"
SITE="https://github.com/infracost/cli/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/${MY_PN}-linux-amd64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( ${SITE}/${MY_PN}-linux-arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

# lichen against both release binaries resolves every embedded Go module to
# Apache-2.0, BSD-3-Clause (-> BSD), MIT, MPL-2.0, or Unlicense, with a
# single exception: github.com/infracost/go-proto@v1.30.0 ships no LICENSE
# file and pkg.go.dev's own scanner reports "None detected" for it too --
# this is not a classifier false positive, it is genuinely missing from
# upstream. go-proto is Infracost's own first-party module (sibling of the
# Apache-2.0 infracost/proto and infracost/config also embedded here) and is
# shipped by its own copyright holder as compiled code inside this
# Apache-2.0-declared infracost/cli release, so it is treated as covered by
# the project's own Apache-2.0 license here; upstream should still be asked
# to add a LICENSE file. apparentlymart/go-textseg additionally carries
# Unicode-DFS-2016 alongside its MIT/Apache-2.0 dual grant. Both amd64 and
# arm64 embed an identical dependency/version set (verified via
# `go version -m`); only the CGO_ENABLED build tag differs between them.
LICENSE="Apache-2.0 BSD MIT MPL-2.0 Unicode-DFS-2016 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The amd64 release binary is dynamically linked against glibc (NEEDED
# libc.so.6); the arm64 release binary is fully static and has no such
# requirement.
REQUIRED_USE="amd64? ( elibc_glibc )"

# Upstream's release binaries are not pre-stripped (both still carry
# .debug_info), so let Portage strip them normally; QA_PREBUILT only
# exempts the prebuilt executable from the QA checks it would otherwise
# spuriously trigger (e.g. the amd64 build is dynamically linked against
# glibc while the arm64 build is fully static -- both link results are
# upstream's own CGO_ENABLED choice per architecture, not a packaging bug).
QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin "${MY_PN}"
}
