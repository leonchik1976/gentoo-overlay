# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Command-line toolkit for developing and deploying AWS CDK applications"
HOMEPAGE="https://github.com/aws/aws-cdk-cli https://aws.amazon.com/cdk/"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"
S="${WORKDIR}/package"

LICENSE="0BSD Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=net-libs/nodejs-22[ssl]"
BDEPEND=">=net-libs/nodejs-22"

src_compile() {
	:
}

src_test() {
	local version

	version=$(node bin/cdk --version) || die "failed to run the CDK CLI"
	[[ ${version} == "${PV} "* ]] ||
		die "unexpected CDK CLI version: ${version}"
}

src_install() {
	insinto /usr/libexec/${PN}
	doins package.json build-info.json db.json.gz release.txt
	doins -r bin lib
	fperms +x /usr/libexec/${PN}/bin/cdk

	dobin "${FILESDIR}/cdk"

	dodoc README.md NOTICE THIRD_PARTY_LICENSES
	dodoc -r docs
}

pkg_postinst() {
	einfo "Individual CDK applications may require Docker or language-specific"
	einfo "toolchains. The AWS CLI is optional and may be useful for configuring"
	einfo "credentials and interactive authentication."
}
