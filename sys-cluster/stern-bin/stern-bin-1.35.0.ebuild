# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN=${PN%-bin}

DESCRIPTION="Multi pod and container log tailing for Kubernetes"
HOMEPAGE="https://github.com/stern/stern"
SRC_URI="
	amd64? (
		https://github.com/stern/stern/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/stern/stern/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S=${WORKDIR}

# Both release binaries embed the same 71 Go module versions and license set.
# lichen flags sigs.k8s.io/yaml as partly ImageMagick-licensed, but a full grep
# of that module's source contains no such license text.  This is a classifier
# false positive against its combined MIT+Apache-2.0+BSD-3-Clause LICENSE file,
# so ImageMagick is deliberately not included here.
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin "${MY_PN}"
	dodoc LICENSE
}
