# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"

DESCRIPTION="Terraform-style CLI to list your existing AWS resources"
HOMEPAGE="https://github.com/jckuester/awsls"
SITE="https://github.com/jckuester/awsls/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/${MY_PN}_${PV}_linux_amd64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( ${SITE}/${MY_PN}_${PV}_linux_arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"

S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own license
# plus every statically-linked dependency's license, audited directly
# against the compiled binary with dev-go/lichen: MIT (own + jckuester/
# hashicorp-cli/mitchellh helpers), Apache-2.0 (aws-sdk-go-v2, the ~100
# per-service modules, grpc), BSD-3-Clause (-> BSD, golang.org/x/*,
# google/*), BSD-2-Clause (-> BSD-2, pkg/errors, vmihailenco), ISC
# (davecgh/go-spew), and MPL-2.0 (the hashicorp/* dependency cluster
# pulled in via awstools-lib/terradozer/terraform internals).
LICENSE="MIT Apache-2.0 BSD BSD-2 ISC MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/bin/awsls"

src_install() {
	dobin awsls
	einstalldocs
}
