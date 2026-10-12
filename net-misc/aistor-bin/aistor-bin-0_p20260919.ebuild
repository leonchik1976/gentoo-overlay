# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# systemd.eclass does not support EAPI 9 yet.
EAPI=8

inherit systemd

DESCRIPTION="MinIO AIStor S3-compatible object storage server"
HOMEPAGE="https://www.min.io/product/aistor"
MY_RELEASE="RELEASE.2026-09-19T17-05-25Z"
SRC_URI="
	amd64? ( https://dl.min.io/aistor/minio/release/linux-amd64/archive/minio.${MY_RELEASE} -> ${P}-amd64 )
	arm64? ( https://dl.min.io/aistor/minio/release/linux-arm64/archive/minio.${MY_RELEASE} -> ${P}-arm64 )
"
S="${WORKDIR}"

LICENSE="MinIO-AIStor-Free"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# The free agreement prohibits redistribution and binary modification.
RESTRICT="bindist mirror strip"

RDEPEND="
	acct-group/aistor
	acct-user/aistor
"
IDEPEND="acct-group/aistor acct-user/aistor"
QA_PREBUILT="usr/bin/aistor"

src_unpack() {
	local arch
	if use amd64; then
		arch=amd64
	elif use arm64; then
		arch=arm64
	else
		die "Unsupported architecture"
	fi
	cp "${DISTDIR}/${P}-${arch}" aistor || die
}

src_install() {
	dobin aistor
	dosym aistor /usr/bin/minio

	insinto /etc/aistor
	doins "${FILESDIR}/aistor.env"
	fperms 0640 /etc/aistor/aistor.env
	exeinto /usr/libexec/aistor
	doexe "${FILESDIR}/check-credentials"
	systemd_dounit "${FILESDIR}/aistor.service"

	keepdir /var/lib/aistor/data
	fperms 0750 /var/lib/aistor /var/lib/aistor/data
}

pkg_preinst() {
	# Resolve the service account at merge time, including for binary packages.
	fowners root:aistor /etc/aistor/aistor.env
	fowners aistor:aistor /var/lib/aistor /var/lib/aistor/data
}

pkg_postinst() {
	elog "Obtain your AIStor Free license from https://www.min.io/pricing"
	elog "Save it as /etc/aistor/aistor.license, readable by the aistor user."
	elog "Set credentials and storage options in /etc/aistor/aistor.env."
	elog "AIStor Free permits single-node deployments only."
	elog "Migration of existing MinIO data to AIStor is irreversible."
	elog "The service uses a separate /var/lib/aistor/data directory by default."
}
