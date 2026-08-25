# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="${PN%-bin}"

DESCRIPTION="Cloud cost estimates for Terraform, Terragrunt, CloudFormation, and AWS CDK"
HOMEPAGE="https://www.infracost.io https://github.com/infracost/infracost"
SITE="https://github.com/infracost/infracost/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/${MY_PN}-linux-amd64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( ${SITE}/${MY_PN}-linux-arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own Apache-2.0
# license plus every statically-linked dependency's license, audited
# directly against the compiled binary with dev-go/lichen: Apache-2.0 (own
# + aws-sdk-go-v2, hashicorp/tflint stack, opentelemetry, grpc, and most
# others), BSD-3-Clause (-> BSD, golang.org/x/*, google.golang.org/api),
# BSD-2-Clause (-> BSD-2, gitlab.com/ code, vmihailenco/*), MIT (urfave/
# cli, spacelift-io/*, tidwall/*, and others), MPL-2.0 (mozilla.org/sops,
# terraform-linters/tflint stack), CC0-1.0 (therootcompany/xz),
# Unlicense, Unicode-DFS-2016. lichen also flags sigs.k8s.io/yaml as
# partly "ImageMagick"-licensed; a direct full-text grep of that
# module's actual source and GOMODCACHE copy contains no such license
# text anywhere -- this is a lichen classifier false positive against
# its concatenated MIT+Apache-2.0+BSD-3-Clause LICENSE file (previously
# assumed genuine in this comment without actually grepping the source;
# corrected), so it is deliberately not included here. lichen flagged
# go.mozilla.org/gopgagent as unresolvable (no LICENSE file in that
# repo); its source file header states "Licensed under the Apache
# License, Version 2.0", confirmed directly against
# raw.githubusercontent.com/mozilla-services/gopgagent/master/gpgagent.go.
LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/infracost"

src_install() {
	newbin "${MY_PN}-linux-$(usex amd64 amd64 arm64)" "${MY_PN}"
}
