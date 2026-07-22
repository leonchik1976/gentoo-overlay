# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="High-throughput FUSE client for mounting Amazon S3 buckets"
HOMEPAGE="https://github.com/awslabs/mountpoint-s3"
SRC_URI="
	amd64? ( https://s3.amazonaws.com/mountpoint-s3-release/${PV}/x86_64/mount-s3-${PV}-x86_64.tar.gz )
	arm64? ( https://s3.amazonaws.com/mountpoint-s3-release/${PV}/arm64/mount-s3-${PV}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT openssl Unicode-3.0 Unicode-DFS-2016 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

RDEPEND="sys-fs/fuse:0"

QA_PREBUILT="usr/bin/mount-s3"

src_install() {
	newbin bin/mount-s3 mount-s3
	dodoc NOTICE THIRD_PARTY_LICENSES
}
