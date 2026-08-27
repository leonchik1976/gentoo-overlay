# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="High-performance, S3-compatible object storage server"
HOMEPAGE="https://min.io/ https://github.com/minio/minio"
SRC_URI="
	https://github.com/minio/minio/archive/refs/tags/RELEASE.2025-10-15T17-29-55Z.tar.gz -> ${P}.tar.gz
	https://github.com/leonchik1976/gentoo-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

S="${WORKDIR}/minio-RELEASE.2025-10-15T17-29-55Z"

# Aggregate of MinIO's own AGPL-3 license and the licenses of all Go
# module dependencies actually linked into the built binary, verified
# with dev-go/lichen against the real offline build and cross-checked
# against each module's own license text in the dependency cache.
# Three MinIO-owned forks of Go stdlib packages (colorjson, csvparser,
# filepath) carry no LICENSE file of their own but retain the
# original "Copyright ... The Go Authors ... BSD-style license"
# header from the stdlib code they fork, matching dev-lang/go's own
# LICENSE="BSD"; github.com/vbauerster/mpb/v8 ships its own UNLICENSE
# file (public domain dedication).
LICENSE="AGPL-3 Apache-2.0 BSD BSD-2 CC0-1.0 EPL-2.0 ISC LGPL-3 MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/minio
	acct-user/minio
"
RDEPEND="${ACCT_DEPEND}"

BDEPEND+=" >=dev-lang/go-1.24.0"

# Upstream's test suite requires networked backends (multiple live
# MinIO nodes, external KMS, cloud object storage credentials) that
# are not available in the Gentoo build sandbox.
RESTRICT="test"

src_compile() {
	local -x CGO_ENABLED=0
	local go_ldflags="-X github.com/minio/minio/cmd.Version=RELEASE.2025-10-15T17-29-55Z"
	go_ldflags+=" -X github.com/minio/minio/cmd.ReleaseTag=RELEASE.2025-10-15T17-29-55Z"
	go_ldflags+=" -X github.com/minio/minio/cmd.CopyrightYear=2025"
	go_ldflags+=" -X github.com/minio/minio/cmd.CommitID=9e49d5e7a648f00e26f2246f4dc28e6b07f8c84a"
	go_ldflags+=" -X github.com/minio/minio/cmd.ShortCommitID=9e49d5e7a648"

	ego build -trimpath -tags kqueue -ldflags "${go_ldflags}" -o minio .
}

src_install() {
	dobin minio

	dodoc README.md CREDITS

	insinto /etc/minio
	newins "${FILESDIR}"/minio.env minio.env
	# minio itself re-opens MINIO_CONFIG_ENV_FILE directly as the
	# unprivileged minio user (not merely via systemd's root-read
	# EnvironmentFile=), so the file must be group-readable by minio,
	# not just root -- verified by an actual failed start otherwise:
	# "FATAL Unable to read the config environment file: ... permission
	# denied".
	fowners root:minio /etc/minio/minio.env
	fperms 0640 /etc/minio/minio.env

	systemd_newunit "${FILESDIR}"/minio.service minio.service

	keepdir /var/lib/minio/data
	fowners -R minio:minio /var/lib/minio
}
