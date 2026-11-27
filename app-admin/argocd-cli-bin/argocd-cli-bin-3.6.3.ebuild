# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Command-line interface for Argo CD"
HOMEPAGE="https://argo-cd.readthedocs.io/ https://github.com/argoproj/argo-cd"
SRC_URI="
	amd64? (
		https://github.com/argoproj/argo-cd/releases/download/v${PV}/argocd-linux-amd64
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/argoproj/argo-cd/releases/download/v${PV}/argocd-linux-arm64
			-> ${P}-arm64
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC imagemagick MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_PREBUILT="usr/bin/argocd"

src_unpack() {
	local artifact

	case ${ARCH} in
		amd64|arm64)
			artifact=${P}-${ARCH}
			;;
		*)
			die "Unsupported architecture: ${ARCH}"
			;;
	esac

	cp "${DISTDIR}/${artifact}" "${S}/argocd" || die
	chmod +x "${S}/argocd" || die
}

src_compile() {
	./argocd completion bash > argocd.bash || die
	./argocd completion zsh > _argocd || die
	./argocd completion fish > argocd.fish || die
}

src_test() {
	./argocd version --client --short || die
	./argocd help >/dev/null || die
}

src_install() {
	dobin argocd

	newbashcomp argocd.bash argocd
	newzshcomp _argocd _argocd
	dofishcomp argocd.fish
}
