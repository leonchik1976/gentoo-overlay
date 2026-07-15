# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

DESCRIPTION="Standalone LocalStack command line interface"
HOMEPAGE="
	https://www.localstack.cloud/
	https://github.com/localstack/localstack-cli
"
SRC_URI="
	amd64? (
		https://github.com/localstack/localstack-cli/releases/download/v${PV}/localstack-cli-${PV}-linux-amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/localstack/localstack-cli/releases/download/v${PV}/localstack-cli-${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"

S="${WORKDIR}/localstack"

LICENSE="
	Apache-2.0 BSD BSD-2 BZIP2 GPL-3+ HPND LGPL-2.1+ MIT MPL-2.0
	openssl PSF-2 ZLIB
	|| ( Artistic GPL-1+ )
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="opt/${PN}/*"

src_install() {
	insinto /opt/${PN}
	doins -r _internal

	exeinto /opt/${PN}
	doexe localstack

	dosym ../../opt/${PN}/localstack /usr/bin/localstack
}

pkg_postinst() {
	optfeature "running LocalStack containers" app-containers/docker
}
