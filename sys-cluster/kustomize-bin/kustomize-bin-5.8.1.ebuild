# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion sysroot toolchain-funcs

MY_PN=${PN%-bin}

DESCRIPTION="Customization of Kubernetes YAML configurations"
HOMEPAGE="https://kustomize.io/ https://github.com/kubernetes-sigs/kustomize"
SRC_URI="
	amd64? (
		https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${PV}/${MY_PN}_v${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${PV}/${MY_PN}_v${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD ISC MIT imagemagick"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/${MY_PN}"

src_compile() {
	local shell

	for shell in bash fish zsh; do
		sysroot_try_run_prefixed ./${MY_PN} completion "${shell}" \
			> "${T}/${MY_PN}.${shell}" || die
	done
}

src_test() {
	if ! tc-is-cross-compiler; then
		[[ $(./${MY_PN} version) == v${PV} ]] || die "Version check failed"
		./${MY_PN} help >/dev/null || die "Help check failed"
	fi
}

src_install() {
	dobin "${MY_PN}"

	[[ -s ${T}/${MY_PN}.bash ]] && newbashcomp "${T}/${MY_PN}.bash" "${MY_PN}"
	[[ -s ${T}/${MY_PN}.fish ]] && dofishcomp "${T}/${MY_PN}.fish"
	[[ -s ${T}/${MY_PN}.zsh ]] && newzshcomp "${T}/${MY_PN}.zsh" "_${MY_PN}"
}
