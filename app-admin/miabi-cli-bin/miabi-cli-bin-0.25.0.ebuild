# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Command-line client and Docker stack manager for Miabi"
HOMEPAGE="https://miabi.io https://github.com/miabi-io/cli"
SRC_URI="
	amd64? (
		https://github.com/miabi-io/cli/releases/download/v${PV}/miabi_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/miabi-io/cli/releases/download/v${PV}/miabi_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

# Includes the statically linked Go dependencies; see docs/miabi-cli-bin-license-audit.md.
LICENSE="AGPL-3+ Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="app-misc/ca-certificates"
BDEPEND="app-arch/xz-utils"

QA_PREBUILT="usr/bin/miabi"

src_prepare() {
	default
	xz -dc "${FILESDIR}/${P}-THIRD-PARTY-LICENSES.xz" > THIRD-PARTY-LICENSES || die
}

src_compile() {
	local shell
	for shell in bash zsh fish; do
		./miabi completion "${shell}" > "miabi.${shell}" || die
	done
}

src_test() {
	./miabi --version || die
	./miabi --help > /dev/null || die
}

src_install() {
	dobin miabi
	dodoc LICENSE README.md
	dodoc THIRD-PARTY-LICENSES

	newbashcomp miabi.bash miabi
	newzshcomp miabi.zsh _miabi
	newfishcomp miabi.fish miabi.fish
}

pkg_postinst() {
	elog "Remote API commands do not need a local Docker daemon."
	elog "To manage a stack on this host, install >=app-containers/docker-25"
	elog "and start a rootful Docker daemon before running miabi setup."
	elog "Stack provisioning is manual and downloads container images."
}
