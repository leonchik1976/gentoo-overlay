# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Policy-as-code DSL and CLI to validate CloudFormation, Terraform, K8s configs"
HOMEPAGE="https://github.com/aws-cloudformation/cloudformation-guard"
SRC_URI="
	amd64? (
		https://github.com/aws-cloudformation/cloudformation-guard/releases/download/${PV}/cfn-guard-v3-x86_64-linux-latest.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/aws-cloudformation/cloudformation-guard/releases/download/${PV}/cfn-guard-v3-aarch64-linux-latest.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
# Statically-linked (musl) Rust binary: LICENSE covers the project's own
# Apache-2.0 license plus the license of every crate in the shipped
# "cfn-guard" binary's own dependency closure (i.e. reachable from its
# Cargo.lock entry, not the whole cargo workspace -- the unbuilt
# "guard-lambda"/"guard-ffi" workspace members pull in unrelated crates
# never linked into this binary), audited via the crates.io API:
# (Apache-2.0 OR MIT) AND BSD-3-Clause -> BSD, BSD-2-Clause -> BSD-2,
# BSL-1.0 -> Boost-1.0, MIT, MPL-2.0, Unicode-3.0, Unlicense.
LICENSE+=" BSD BSD-2 Boost-1.0 MIT MPL-2.0 Unicode-3.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_PREBUILT="usr/bin/cfn-guard"

src_install() {
	local arch_dir="cfn-guard-v3-$(usex amd64 x86_64 aarch64)-linux-latest"

	newbin "${arch_dir}/cfn-guard" cfn-guard
	dodoc "${arch_dir}/README.md"
}
