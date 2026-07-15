# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

MY_PN=${PN%-bin}

DESCRIPTION="Command-line utility for the Istio service mesh"
HOMEPAGE="https://istio.io/ https://github.com/istio/istio"
SRC_URI="
	amd64? (
		https://github.com/istio/istio/releases/download/${PV}/${MY_PN}-${PV}-linux-amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/istio/istio/releases/download/${PV}/${MY_PN}-${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC imagemagick MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	local -x GOMAXPROCS=1
	local -x HOME="${T}"

	dobin "${MY_PN}"

	timeout 60s "./${MY_PN}" completion bash > "${T}/${MY_PN}.bash" ||
		die "Failed to generate bash completion"
	newbashcomp "${T}/${MY_PN}.bash" "${MY_PN}"

	timeout 60s "./${MY_PN}" completion fish > "${T}/${MY_PN}.fish" ||
		die "Failed to generate fish completion"
	newfishcomp "${T}/${MY_PN}.fish" "${MY_PN}.fish"

	timeout 60s "./${MY_PN}" completion zsh > "${T}/${MY_PN}.zsh" ||
		die "Failed to generate zsh completion"
	newzshcomp "${T}/${MY_PN}.zsh" "_${MY_PN}"
}
