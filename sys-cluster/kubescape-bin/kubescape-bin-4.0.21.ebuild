# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="${PN%-bin}"

DESCRIPTION="Kubernetes security, compliance, and posture management CLI"
HOMEPAGE="https://kubescape.io/ https://github.com/kubescape/kubescape"
SRC_URI="
	amd64? (
		https://github.com/kubescape/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/kubescape/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

# Prebuilt statically linked Go binary: full dependency closure audited
# with dev-go/lichen against both the amd64 and arm64 release binaries
# (identical resolved module/license set on both arches, aside from
# nondeterministic map-iteration ordering in lichen's own output).
# Two modules came back "unresolvable license" on both arches, resolved
# manually against upstream: github.com/alibabacloud-go/cr-20160607 is
# Apache-2.0 (confirmed via the GitHub API license field and its
# LICENSE file text, already covered below); github.com/xi2/xz is
# public domain (confirmed via its LICENSE file: "All these files have
# been put into the public domain").
# Resolved licenses: Apache-2.0 (own + most deps), BSD-3-Clause
# (-> BSD, golang.org/x/*), BSD-2-Clause + BSD-2-Clause-FreeBSD
# (-> BSD-2), 0BSD, ISC, MIT, MPL-2.0, CC0-1.0, Unlicense,
# Unicode-DFS-2016. github.com/spdx/tools-golang is dual-licensed
# "Apache-2.0 OR GPL-2.0-or-later" (its own LICENSE.code) with docs
# under CC-BY-4.0 (LICENSE.docs); the Apache-2.0 option is elected, so
# GPL-2.0/LGPL-2.0 (which lichen also reported for this module, though
# LGPL text does not actually appear in LICENSE.code) are not included.
# github.com/opencontainers/go-digest is similarly dual Apache-2.0
# (code) + CC-BY-SA-4.0 (docs, its own LICENSE.docs). In both cases
# only the compiled code (Apache-2.0) actually ends up in the binary
# this ebuild installs; CC-BY-4.0/CC-BY-SA-4.0 cover documentation
# that is never fetched or shipped by this -bin package, so neither is
# included here. lichen also flags sigs.k8s.io/yaml as partly
# "ImageMagick"-licensed; a direct full-text grep of that module's
# actual source and GOMODCACHE copy contains no such license text
# anywhere -- a lichen classifier false positive against its
# concatenated MIT+Apache-2.0+BSD-3-Clause LICENSE file, so it is
# deliberately not included here either.
LICENSE="0BSD Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin "${MY_PN}"
	dodoc README.md

	elog "kubescape fetches Kubernetes security framework/control definitions"
	elog "from a remote registry at scan time by default. For fully offline"
	elog "use, pre-fetch them once with network access, then scan offline:"
	elog "  kubescape download artifacts --output <dir>"
	elog "  kubescape scan --use-artifacts-from <dir>"
}
