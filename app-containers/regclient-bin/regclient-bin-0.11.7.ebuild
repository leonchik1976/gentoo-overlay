# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Docker and OCI registry clients, upstream binary distribution"
HOMEPAGE="https://regclient.org/ https://github.com/regclient/regclient"
SRC_URI="
	amd64? (
		https://github.com/regclient/regclient/releases/download/v${PV}/regctl-linux-amd64 -> ${P}-regctl-amd64
		https://github.com/regclient/regclient/releases/download/v${PV}/regsync-linux-amd64 -> ${P}-regsync-amd64
		https://github.com/regclient/regclient/releases/download/v${PV}/regbot-linux-amd64 -> ${P}-regbot-amd64
	)
	arm64? (
		https://github.com/regclient/regclient/releases/download/v${PV}/regctl-linux-arm64 -> ${P}-regctl-arm64
		https://github.com/regclient/regclient/releases/download/v${PV}/regsync-linux-arm64 -> ${P}-regsync-arm64
		https://github.com/regclient/regclient/releases/download/v${PV}/regbot-linux-arm64 -> ${P}-regbot-arm64
	)
	https://github.com/regclient/regclient/archive/refs/tags/v${PV}.tar.gz
		-> regclient-${PV}.tar.gz
"
S="${WORKDIR}/regclient-${PV}"

# Project source/docs and the exact embedded Go modules.
LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="!app-containers/regclient"
BDEPEND="app-arch/xz-utils"
QA_PREBUILT="usr/bin/regctl usr/bin/regsync usr/bin/regbot"

src_compile() {
	local cmd
	mkdir -p bin || die
	for cmd in regctl regsync regbot; do
		cp "${DISTDIR}/${P}-${cmd}-${ARCH}" "bin/${cmd}" || die
		chmod +x "bin/${cmd}" || die
		"./bin/${cmd}" completion bash > "${cmd}.bash" || die
		"./bin/${cmd}" completion zsh > "${cmd}.zsh" || die
		"./bin/${cmd}" completion fish > "${cmd}.fish" || die
	done
}

src_test() {
	local cmd
	for cmd in regctl regsync regbot; do
		"./bin/${cmd}" version || die
	done
}

src_install() {
	dobin bin/regctl bin/regsync bin/regbot
	einstalldocs
	dodoc LICENSE
	dodoc -r docs
	docinto examples
	dodoc cmd/regbot/testdata/*.yml cmd/regsync/testdata/*.yml
	docinto /

	local cmd
	for cmd in regctl regsync regbot; do
		newbashcomp "${cmd}.bash" "${cmd}"
		newzshcomp "${cmd}.zsh" "_${cmd}"
		dofishcomp "${cmd}.fish"
	done

	local notices="${T}/notices"
	mkdir -p "${notices}" || die
	tar -xJf "${FILESDIR}/${P}-notices.tar.xz" -C "${notices}" || die
	docinto third-party-notices
	dodoc -r "${notices}/."
}
