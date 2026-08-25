# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN=${PN%-bin}

DESCRIPTION="CLI for Envoy Gateway (egctl only, not the full control plane)"
HOMEPAGE="https://gateway.envoyproxy.io/ https://github.com/envoyproxy/gateway"
SRC_URI="
	amd64? (
		https://github.com/envoyproxy/gateway/releases/download/v${PV}/${MY_PN}_v${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/envoyproxy/gateway/releases/download/v${PV}/${MY_PN}_v${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

# Prebuilt statically linked Go binary: full dependency closure audited
# with dev-go/lichen against both the amd64 and arm64 release binaries
# (identical resolved module/license set on both arches). No unresolved
# modules. Own license + all resolved deps: Apache-2.0 (own + most
# deps), BSD-3-Clause (-> BSD, golang.org/x/*), BSD-2-Clause (-> BSD-2),
# MIT, MPL-2.0, ISC. github.com/opencontainers/go-digest is dual
# Apache-2.0 (code, LICENSE) + CC-BY-SA-4.0 (docs, LICENSE.docs) --
# confirmed directly against both files upstream. Only the compiled
# code (Apache-2.0) actually ends up in the binary this ebuild
# installs; CC-BY-SA-4.0 covers go-digest's documentation, which is
# never fetched or shipped by this -bin package, so it is not
# included here. lichen also flags sigs.k8s.io/yaml as partly
# "ImageMagick"-licensed; a direct full-text grep of that module's
# actual source and GOMODCACHE copy contains no such license text
# anywhere -- a lichen classifier false positive against its
# concatenated MIT+Apache-2.0+BSD-3-Clause LICENSE file, so it is
# deliberately not included here either.
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	newbin "bin/linux/$(usex amd64 amd64 arm64)/${MY_PN}" "${MY_PN}"
}
