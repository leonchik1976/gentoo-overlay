# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="AWS CDK wrapper for deploying applications to LocalStack"
HOMEPAGE="https://github.com/localstack/aws-cdk-local"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"
S="${WORKDIR}/package"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-libs/node-diff-5.0.0
	<dev-libs/node-diff-6
	>=dev-libs/node-semver-7.7.4
	<dev-libs/node-semver-8
	>=dev-util/aws-cdk-2.1113.0
	<dev-util/aws-cdk-3
	>=net-libs/nodejs-22[ssl]
"
BDEPEND=">=net-libs/nodejs-22"

src_compile() {
	:
}

src_test() {
	node --check bin/cdklocal || die "cdklocal syntax check failed"
	node --check src/index.js || die "support library syntax check failed"
}

src_install() {
	insinto /usr/libexec/${PN}
	doins package.json
	doins -r bin src
	fperms +x /usr/libexec/${PN}/bin/cdklocal

	dobin "${FILESDIR}/cdklocal"
	dodoc README.md
}

pkg_postinst() {
	einfo "Deploying with cdklocal requires a reachable LocalStack endpoint."
	einfo "The endpoint may be local or remote, so the LocalStack CLI and"
	einfo "a local container runtime are optional."
}
