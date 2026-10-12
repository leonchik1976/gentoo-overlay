# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="MinIO Warp benchmark tool for S3-compatible object storage"
HOMEPAGE="https://www.min.io/download/minio-warp https://github.com/minio/warp"
SRC_URI="
	https://github.com/minio/warp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	amd64? ( https://dl.min.io/aistor/warp/release/linux-amd64/archive/warp.v${PV} -> ${P}-amd64 )
	arm64? ( https://dl.min.io/aistor/warp/release/linux-arm64/archive/warp.v${PV} -> ${P}-arm64 )
"
S="${WORKDIR}/warp-${PV}"

# Includes licenses of the modules linked into the upstream binary.
LICENSE="AGPL-3 Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"
QA_PREBUILT="usr/bin/minio-warp"

# The client uses the system certificate pool for HTTPS endpoints.
RDEPEND="app-misc/ca-certificates"
BDEPEND="app-arch/xz-utils"

DOCS=( README.md NOTICE LICENSE )

src_unpack() {
	unpack "${P}.tar.gz"
	local notices
	for notices in "${FILESDIR}"/third-party-licenses-*.txt.xz; do
		unpack "${notices}"
	done
	local arch
	if use amd64; then
		arch=amd64
	elif use arm64; then
		arch=arm64
	else
		die "Unsupported architecture"
	fi
	cp "${DISTDIR}/${P}-${arch}" "${S}/minio-warp" || die
	chmod +x "${S}/minio-warp" || die
}

src_test() {
	./minio-warp --version || die
	# Exercise offline decompression and analysis of upstream test data.
	./minio-warp analyze --no-color \
		pkg/bench/testdata/warp-benchdata-get.csv.zst > "${T}/analysis.txt" || die
	grep -q 'Report: GET (20948 reqs)' "${T}/analysis.txt" || die "GET analysis missing"
	grep -q 'Report: PUT (1000 reqs)' "${T}/analysis.txt" || die "PUT analysis missing"
	einfo "Offline analysis: GET 20948 requests and PUT 1000 requests verified"
}

src_install() {
	dobin minio-warp
	einstalldocs
	dodoc "${WORKDIR}"/third-party-licenses-*.txt
}

pkg_postinst() {
	elog "The MinIO Warp executable is installed as minio-warp to avoid command-name collisions."
	elog "Use minio-warp in place of warp in upstream examples."
}
