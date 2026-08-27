# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN=${PN%-bin}

DESCRIPTION="Use AWS IAM credentials to authenticate to a Kubernetes cluster"
HOMEPAGE="https://github.com/kubernetes-sigs/aws-iam-authenticator"
SRC_URI="
	amd64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64
			-> ${P}-arm64
	)
"
S=${WORKDIR}

# Upstream's statically linked release binaries embed the same dependency
# versions as the v${PV} source tree.  The dependency license closure was
# audited directly for the former source ebuild and confirmed against the Go
# build information embedded in both release binaries.  lichen flags
# sigs.k8s.io/yaml as partly ImageMagick-licensed, but a full grep of that
# module's actual source contains no such license text.  This is a classifier
# false positive against its concatenated MIT+Apache-2.0+BSD-3-Clause LICENSE
# file, so ImageMagick is deliberately not included here.
LICENSE="Apache-2.0 BSD ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" "${MY_PN}"
}
