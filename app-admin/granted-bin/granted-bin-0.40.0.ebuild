# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="AWS credential management CLI, upstream binary distribution"
HOMEPAGE="https://granted.dev https://github.com/fwdcloudsec/granted"
SRC_URI="
	amd64? (
		https://github.com/fwdcloudsec/granted/releases/download/v${PV}/granted_${PV}_linux_x86_64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/fwdcloudsec/granted/releases/download/v${PV}/granted_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
	https://github.com/fwdcloudsec/granted/archive/refs/tags/v${PV}.tar.gz
		-> granted-${PV}.tar.gz
"
S="${WORKDIR}"

# Main LICENCE and exact embedded Go-module license texts.
LICENSE="MIT Apache-2.0 BSD BSD-2 MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="!app-admin/granted"
BDEPEND="app-arch/xz-utils"
QA_PREBUILT="usr/bin/granted usr/bin/assumego"

src_compile() {
	:
}

src_test() {
	./granted --version || die
}

src_install() {
	dobin granted assumego
	insinto /usr/share/granted
	doins assume assume.fish "granted-${PV}/scripts/assume.tcsh"
	dodoc "granted-${PV}/README.md"
	newdoc "granted-${PV}/LICENCE" LICENSE

	local notices="${T}/notices"
	mkdir -p "${notices}" || die
	tar -xJf "${FILESDIR}/${P}-notices.tar.xz" -C "${notices}" || die
	docinto third-party-notices
	dodoc -r "${notices}/."
}

pkg_postinst() {
	elog "Source the script for your shell from /usr/share/granted/ to use"
	elog "the assume shell function: assume, assume.fish, or assume.tcsh."
}
