# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd tmpfiles

MY_PN="${PN%-bin}"
MY_ARCH="${ARCH/amd64/x86_64}"
MY_P="${MY_PN}-${PV}-linux-${MY_ARCH}"

DESCRIPTION="Lightweight log shipper for Logstash and Elasticsearch"
HOMEPAGE="https://www.elastic.co/beats/filebeat"
SRC_URI="
	amd64? ( https://artifacts.elastic.co/downloads/beats/${MY_PN}/${MY_PN}-${PV}-linux-x86_64.tar.gz )
	arm64? ( https://artifacts.elastic.co/downloads/beats/${MY_PN}/${MY_PN}-${PV}-linux-arm64.tar.gz )
"

S="${WORKDIR}/${MY_P}"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 Elastic EPL-2.0 GPL-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	!app-admin/filebeat
	sys-libs/glibc
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin "${MY_PN}"
	dodoc NOTICE.txt README.md

	insinto "/etc/${MY_PN}"
	doins fields.yml "${MY_PN}.yml" "${MY_PN}.reference.yml"
	doins -r modules.d

	insinto "/usr/share/${MY_PN}"
	doins -r kibana module

	newconfd "${FILESDIR}/${MY_PN}.confd" "${MY_PN}"
	newinitd "${FILESDIR}/${MY_PN}.initd" "${MY_PN}"
	systemd_dounit "${FILESDIR}/${MY_PN}.service"
	dotmpfiles "${FILESDIR}/${MY_PN}.conf"
}

pkg_postinst() {
	tmpfiles_process "${MY_PN}.conf"
}
