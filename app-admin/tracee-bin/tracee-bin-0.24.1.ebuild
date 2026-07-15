# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

MY_PN="${PN%-bin}"

DESCRIPTION="Runtime security and forensics using eBPF"
HOMEPAGE="https://github.com/aquasecurity/tracee"
SRC_URI="
	amd64? (
		https://github.com/aquasecurity/${MY_PN}/releases/download/v${PV}/${MY_PN}-x86_64.v${PV}.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/aquasecurity/${MY_PN}/releases/download/v${PV}/${MY_PN}-aarch64.v${PV}.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 GPL-2 GPL-2-with-font-exception ISC LGPL-2 MIT MPL-2.0 imagemagick"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	app-arch/zstd
	dev-libs/elfutils
	virtual/zlib
"

QA_PREBUILT="
	usr/bin/${MY_PN}
"

src_install() {
	dobin dist/${MY_PN}

	doman dist/docs/man/*.1
	dodoc LICENSE

	case $(uname -m):${ARCH} in
		x86_64:amd64|aarch64:arm64)
			local -x HOME="${T}"

			./dist/${MY_PN} completion bash > "${T}/${MY_PN}.bash" || die
			newbashcomp "${T}/${MY_PN}.bash" "${MY_PN}"

			./dist/${MY_PN} completion zsh > "${T}/${MY_PN}.zsh" || die
			newzshcomp "${T}/${MY_PN}.zsh" "_${MY_PN}"

			./dist/${MY_PN} completion fish > "${T}/${MY_PN}.fish" || die
			dofishcomp "${T}/${MY_PN}.fish"
			;;
		*)
			ewarn "Skipping shell completion generation: ${MY_PN} cannot run on this build host"
			;;
	esac
}
