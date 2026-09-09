# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

MY_PN="${PN%-bin}"

DESCRIPTION="K9s-inspired terminal UI for monitoring Argo CD resources in real time"
HOMEPAGE="https://github.com/vvrnv/argo9s"
SRC_URI="
	amd64? (
		https://github.com/vvrnv/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz
			-> ${P}-linux-amd64.tar.gz
	)
	arm64? (
		https://github.com/vvrnv/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.tar.gz
			-> ${P}-linux-arm64.tar.gz
	)
"
S="${WORKDIR}"

# argo9s itself is MIT; the other tokens cover Go modules statically linked
# into the upstream binary. Verified against the license file of every module
# in `go list -deps ./cmd/argo9s` for v0.1.0 (Apache-2.0: k8s.io/*, cobra, …;
# BSD: golang.org/x/*, protobuf, …; BSD-2: github.com/pkg/errors;
# ISC: github.com/davecgh/go-spew).
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_PREBUILT="usr/bin/argo9s"

src_compile() {
	./argo9s completion bash > argo9s.bash || die
	./argo9s completion zsh > _argo9s || die
	./argo9s completion fish > argo9s.fish || die
}

src_test() {
	./argo9s version || die
	./argo9s help >/dev/null || die
}

src_install() {
	dobin argo9s

	newbashcomp argo9s.bash argo9s
	dozshcomp _argo9s
	dofishcomp argo9s.fish

	dodoc README.md
}
