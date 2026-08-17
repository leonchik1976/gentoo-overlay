# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tool to visualize dynamic node usage within an EKS cluster"
HOMEPAGE="https://github.com/awslabs/eks-node-viewer"
SITE="https://github.com/awslabs/eks-node-viewer/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/eks-node-viewer_Linux_x86_64 -> ${P}-linux-amd64 )
	arm64? ( ${SITE}/eks-node-viewer_Linux_arm64 -> ${P}-linux-arm64 )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own license
# plus every statically-linked dependency's license, audited directly
# against the compiled binary with dev-go/lichen: Apache-2.0 (own +
# aws-sdk-go-v2/k8s.io/sigs.k8s.io stack), MIT (charmbracelet stack and
# others), ISC (davecgh/go-spew), BSD-3-Clause (-> BSD, golang.org/x/*),
# BSD-2-Clause (-> BSD-2, pkg/errors), and imagemagick (one of several
# license texts bundled in sigs.k8s.io/yaml's own LICENSE file, which
# concatenates multiple licenses from code it vendors/forks -- confirmed
# directly, not a lichen misdetection: GitHub's own classifier also
# cannot auto-categorize that file as a single standard license).
LICENSE="Apache-2.0 MIT ISC BSD BSD-2 imagemagick"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="usr/bin/eks-node-viewer"

src_install() {
	# The fetched asset is a raw binary with no recognized archive suffix,
	# so default src_unpack skips it entirely rather than copying it into
	# WORKDIR (see PMS unpack()); fetch it straight from DISTDIR instead.
	newbin "${DISTDIR}/${P}-linux-$(usex amd64 amd64 arm64)" eks-node-viewer
}
