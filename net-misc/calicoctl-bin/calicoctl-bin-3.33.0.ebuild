# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Command-line tool for managing Calico resources (upstream binary)"
HOMEPAGE="https://www.tigera.io/project-calico/ https://github.com/projectcalico/calico"
SRC_URI="
	https://github.com/projectcalico/calico/archive/refs/tags/v${PV}.tar.gz -> calico-${PV}.tar.gz
	amd64? ( https://github.com/projectcalico/calico/releases/download/v${PV}/calicoctl-linux-amd64
		-> calicoctl-${PV}-linux-amd64 )
	arm64? ( https://github.com/projectcalico/calico/releases/download/v${PV}/calicoctl-linux-arm64
		-> calicoctl-${PV}-linux-arm64 )
"
S="${WORKDIR}/calico-${PV}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"
QA_PREBUILT="usr/bin/calicoctl"

BDEPEND="app-arch/xz-utils"

RDEPEND="app-misc/ca-certificates"

src_unpack() {
	unpack "calico-${PV}.tar.gz"
	unpack "${FILESDIR}/third-party-licenses-3.33.0.txt.xz"
}

src_compile() { :; }

src_install() {
	local arch
	if use amd64; then
		arch=amd64
	elif use arm64; then
		arch=arm64
	else
		die "Unsupported architecture"
	fi
	newbin "${DISTDIR}/calicoctl-${PV}-linux-${arch}" calicoctl
	dodoc LICENSE.md
	dodoc "${WORKDIR}/third-party-licenses-3.33.0.txt"
}

pkg_postinst() {
	elog "Use a calicoctl release matching the version of your Calico cluster."
	elog "Configure access with KUBECONFIG or /etc/calico/calicoctl.cfg."
}
