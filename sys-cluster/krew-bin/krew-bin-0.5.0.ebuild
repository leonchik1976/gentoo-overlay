# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN=${PN%-bin}

DESCRIPTION="Plugin manager for kubectl"
HOMEPAGE="https://krew.sigs.k8s.io/ https://github.com/kubernetes-sigs/krew"
SRC_URI="
	amd64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}-linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 MIT imagemagick"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	dev-vcs/git
	>=sys-cluster/kubectl-1.12
"

QA_PREBUILT="usr/bin/kubectl-${MY_PN}"

src_install() {
	newbin "${MY_PN}-linux_${ARCH}" "kubectl-${MY_PN}"
}

pkg_postinst() {
	elog "Add \${KREW_ROOT:-\${HOME}/.krew}/bin to PATH to use plugins installed by Krew."
}
