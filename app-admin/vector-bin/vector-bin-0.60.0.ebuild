# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN=${PN%-bin}

DESCRIPTION="High-performance observability data pipeline"
HOMEPAGE="https://vector.dev/ https://github.com/vectordotdev/vector"
SRC_URI="
	amd64? (
		https://github.com/vectordotdev/vector/releases/download/v${PV}/${MY_PN}-${PV}-x86_64-unknown-linux-gnu.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/vectordotdev/vector/releases/download/v${PV}/${MY_PN}-${PV}-aarch64-unknown-linux-gnu.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S=${WORKDIR}

LICENSE="
	0BSD Apache-2.0 BlueOak-1.0.0 Boost-1.0 BSD BSD-2 CC0-1.0
	CDLA-Permissive-2.0 ISC MIT MIT-0 MPL-2.0 openssl Unicode-3.0
	Unicode-DFS-2016 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="strip"

RDEPEND="
	acct-user/vector
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	elibc_glibc? ( >=sys-libs/glibc-2.28 )
	virtual/zlib:0/1
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	local archive_dir

	case ${ARCH} in
		amd64) archive_dir=${MY_PN}-x86_64-unknown-linux-gnu ;;
		arm64) archive_dir=${MY_PN}-aarch64-unknown-linux-gnu ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	dobin "${archive_dir}/bin/${MY_PN}"

	keepdir /etc/${MY_PN}
	insinto /usr/share/${MY_PN}/examples
	newins "${archive_dir}/config/${MY_PN}.yaml" "${MY_PN}.yaml"
	doins -r "${archive_dir}"/config/examples/*

	dodoc \
		"${archive_dir}"/{LICENSE,LICENSE-3rdparty.csv,NOTICE,README.md} \
		"${archive_dir}/config/README.md"
	docinto licenses
	dodoc "${archive_dir}"/licenses/*

	newinitd "${FILESDIR}/${MY_PN}.initd" "${MY_PN}"
	newconfd "${FILESDIR}/${MY_PN}.confd" "${MY_PN}"
	systemd_dounit "${FILESDIR}/${MY_PN}.service"
}

pkg_postinst() {
	elog "Vector does not install an active configuration by default."
	elog "Create /etc/vector/vector.yaml before enabling the service."
	elog "An upstream example is installed at /usr/share/vector/examples/vector.yaml."
}
