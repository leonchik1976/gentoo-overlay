# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit optfeature shell-completion

DESCRIPTION="Command-line interface for LocalStack"
HOMEPAGE="https://github.com/localstack/lstk"
SRC_URI="
	amd64? (
		https://github.com/localstack/lstk/releases/download/v${PV}/lstk_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/localstack/lstk/releases/download/v${PV}/lstk_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 MIT MPL-2.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip"
QA_PREBUILT="usr/bin/lstk"

src_install() {
	dobin lstk

	newbashcomp completions/lstk.bash lstk
	dofishcomp completions/lstk.fish
	newzshcomp completions/lstk.zsh _lstk

	doman manpages/*.1
}

pkg_postinst() {
	optfeature "running LocalStack containers locally" app-containers/docker
}
