# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion toolchain-funcs

MY_PN="${PN%-bin}"

DESCRIPTION="Utility to create, view, and transform Software Bills of Materials"
HOMEPAGE="https://github.com/kubernetes-sigs/bom"
SRC_URI="
	amd64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}-amd64-linux
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/kubernetes-sigs/${MY_PN}/releases/download/v${PV}/${MY_PN}-arm64-linux
			-> ${P}-arm64
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC MIT imagemagick"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

src_unpack() {
	local asset

	case ${ARCH} in
		amd64) asset=${P}-amd64 ;;
		arm64) asset=${P}-arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	cp "${DISTDIR}/${asset}" "${MY_PN}" || die
	chmod 0755 "${MY_PN}" || die
}

src_install() {
        dobin "${MY_PN}"

        if ! tc-is-cross-compiler; then
                local -x HOME="${T}"

                ./"${MY_PN}" completion bash > "${T}/${MY_PN}.bash" || die
                newbashcomp "${T}/${MY_PN}.bash" "${MY_PN}"

                ./"${MY_PN}" completion zsh > "${T}/${MY_PN}.zsh" || die
                newzshcomp "${T}/${MY_PN}.zsh" "_${MY_PN}"

                ./"${MY_PN}" completion fish > "${T}/${MY_PN}.fish" || die
                dofishcomp "${T}/${MY_PN}.fish"
        fi
}
