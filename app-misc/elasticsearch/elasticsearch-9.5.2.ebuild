# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd tmpfiles

# lib/platform/linux-<arch>/ uses "x64"/"aarch64"; modules/x-pack-ml/platform/
# linux-<arch>/ (and the release tarball suffix) uses "x86_64"/"aarch64".
MY_LIB_ARCH="${ARCH/amd64/x64}"
MY_LIB_ARCH="${MY_LIB_ARCH/arm64/aarch64}"
MY_ML_ARCH="${ARCH/amd64/x86_64}"
MY_ML_ARCH="${MY_ML_ARCH/arm64/aarch64}"

DESCRIPTION="Free and Open, Distributed, RESTful Search Engine"
HOMEPAGE="https://www.elastic.co/elasticsearch/"
SRC_URI="
	amd64? ( https://artifacts.elastic.co/downloads/${PN}/${P}-linux-x86_64.tar.gz )
	arm64? ( https://artifacts.elastic.co/downloads/${PN}/${P}-linux-aarch64.tar.gz )
"

LICENSE="Apache-2.0 BSD-2 Elastic-2.0 LGPL-3 MIT public-domain"
SLOT="0/9"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

DEPEND="acct-group/elasticsearch
	acct-user/elasticsearch"
# This package _actually does depend_ on JDK at runtime. #950962
# sys-libs/glibc: the prebuilt platform libraries and x-pack-ml binaries
# (lib/platform/linux-*/*.so, modules/x-pack-ml/platform/linux-*/{bin,lib}/*)
# are dynamically linked against libc.so.6/GLIBC_2.x; verified with readelf.
RDEPEND="acct-group/elasticsearch
	acct-user/elasticsearch
	sys-libs/glibc
	virtual/zlib:=
	virtual/jdk:21"

QA_FLAGS_IGNORED="usr/share/elasticsearch/lib/platform/linux-${MY_LIB_ARCH}/*.so"
QA_PREBUILT="
	usr/share/elasticsearch/lib/platform/linux-${MY_LIB_ARCH}/*.so
	usr/share/elasticsearch/modules/x-pack-ml/platform/linux-${MY_ML_ARCH}/\(bin\|lib\)/.*
	usr/share/elasticsearch/lib/tools/server-launcher/server-launcher
"
# New in 9.5.2: a native (non-JVM) server-launcher binary shipped alongside
# the old server-cli/*.jar tooling; confirmed via readelf to be a prebuilt,
# glibc-linked, stripped executable, same as the platform/x-pack-ml binaries.
QA_PRESTRIPPED="
	usr/share/elasticsearch/lib/platform/linux-${MY_LIB_ARCH}/*.so
	usr/share/elasticsearch/modules/x-pack-ml/platform/linux-${MY_ML_ARCH}/\(bin\|lib\)/.*
	usr/share/elasticsearch/lib/tools/server-launcher/server-launcher
"

PATCHES=(
	"${FILESDIR}/${PN}-env-3.patch"
)

src_prepare() {
	default

	rm -rf jdk || die
	sed -i -e "s|#\(path.logs:\).*|\1 ${EPREFIX}/var/log/${PN}/|g" config/elasticsearch.yml ||
		die "Unable to set Elasticsearch log location"
	# elasticsearch-env sets the envvar for the config location if not specified elsewhere;
	# certain utilities try and source this. Although we patch ES_JAVA_HOME for Gentoo slightly earlier,
	# it's easier to respect EPREFIX for the config location using sed.
	sed -i "s:ES_PATH_CONF=\"\$ES_HOME\"/config:ES_PATH_CONF=\"${EPREFIX}/etc/${PN}\":" bin/elasticsearch-env  \
		|| die "Unable to set Elasticsearch config directory"
	rm LICENSE.txt NOTICE.txt || die
	rmdir logs || die
}

src_install() {
	keepdir /etc/${PN}
	keepdir /etc/${PN}/scripts

	insinto /etc/${PN}
	doins -r config/.
	rm -r config || die

	fowners -R root:${PN} /etc/${PN}
	fperms -R 2750 /etc/${PN}

	insinto /usr/share/${PN}
	doins -r .

	exeinto /usr/share/${PN}/bin
	doexe "${FILESDIR}"/elasticsearch-systemd-pre-exec

	fperms -R +x /usr/share/${PN}/bin
	fperms -R +x /usr/share/${PN}/modules/x-pack-ml/platform/linux-${MY_ML_ARCH}/bin
	fperms +x /usr/share/${PN}/lib/tools/server-launcher/server-launcher

	keepdir /var/{lib,log}/${PN}
	fowners ${PN}:${PN} /var/{lib,log}/${PN}
	fperms 0750 /var/{lib,log}/${PN}

	insinto /etc/sysctl.d
	newins "${FILESDIR}/${PN}.sysctl.d" ${PN}.conf

	newconfd "${FILESDIR}/${PN}.conf.4" ${PN}
	newinitd "${FILESDIR}/${PN}.init.8" ${PN}

	systemd_install_serviced "${FILESDIR}/${PN}.service.conf"
	systemd_newunit "${FILESDIR}"/${PN}.service.4 ${PN}.service

	newtmpfiles "${FILESDIR}"/${PN}.tmpfiles.d ${PN}.conf
}

pkg_postinst() {
	# Elasticsearch will choke on our keep file and dodir will not preserve the empty dir
	# `equery check` complains that the keep file doesn't exist if we simply remove it
	if [[ ! -d "${EROOT}/usr/share/${PN}/plugins" ]] ; then
		mkdir "${EROOT}/usr/share/${PN}/plugins" || die
	fi
	tmpfiles_process /usr/lib/tmpfiles.d/${PN}.conf
	if ! systemd_is_booted ; then
		elog "You may create multiple instances of ${PN} by"
		elog "symlinking the init script:"
		elog "ln -sf /etc/init.d/${PN} /etc/init.d/${PN}.instance"
		elog
		elog "Please make sure you put elasticsearch.yml, log4j2.properties and scripts"
		elog "from /etc/${PN} into the configuration directory of the instance:"
		elog "/etc/${PN}/instance"
		elog
	fi
	ewarn "Please make sure you have proper permissions on /etc/${PN}"
	ewarn "prior to keystore generation or you may experience startup failures."
	ewarn "chown root:${PN} /etc/${PN} && chmod 2750 /etc/${PN}"
	ewarn "chown root:${PN} /etc/${PN}/${PN}.keystore && chmod 0660 /etc/${PN}/${PN}.keystore"
}
