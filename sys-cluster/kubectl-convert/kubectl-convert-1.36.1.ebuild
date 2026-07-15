# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="kubectl plugin for converting Kubernetes manifests between API versions"
HOMEPAGE="https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
SRC_URI="https://github.com/kubernetes/kubernetes/archive/v${PV}.tar.gz -> kubernetes-${PV}.tar.gz"

S="${WORKDIR}/kubernetes-${PV}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC MIT imagemagick"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The Kubernetes test suite requires extensive integration infrastructure.
RESTRICT="test"

BDEPEND+=" >=dev-lang/go-1.26.0"
RDEPEND="
	>=sys-cluster/kubectl-1.36.0
	<sys-cluster/kubectl-1.37.0
"

QA_PRESTRIPPED="usr/bin/kubectl-convert"

src_compile() {
	emake -j1 \
		GOFLAGS="${GOFLAGS}" \
		GOLDFLAGS="" \
		LDFLAGS="" \
		FORCE_HOST_GO=yes \
		KUBE_BUILD_PLATFORMS="${GOOS}/${GOARCH}" \
		KUBE_${GOOS@U}_${GOARCH@U}_CC="${CC}" \
		WHAT="cmd/${PN}"
}

src_install() {
	dobin "_output/local/bin/${GOOS}/${GOARCH}/${PN}"
}
