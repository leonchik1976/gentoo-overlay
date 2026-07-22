# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# systemd.eclass currently supports EAPI 7 and 8 only.
EAPI=8

inherit systemd

DESCRIPTION="Self-managed code quality and security analysis platform"
HOMEPAGE="https://www.sonarsource.com/products/sonarqube/downloads/"
SRC_URI="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${PV}.zip"
S="${WORKDIR}/sonarqube-${PV}"

LICENSE="
	LGPL-3 Sonar-Source-Available-1.0.1
	Elastic-2.0 SonarSource-SVNKit-SQLJet
	0BSD Apache-2.0 BSD BSD-2 CDDL EPL-1.0 EPL-2.0
	GPL-2-with-classpath-exception LGPL-2.1 MIT MPL-1.1 MPL-2.0
	public-domain W3C WTFPL-2
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror strip"

BDEPEND+="
	app-arch/unzip
	acct-group/sonarqube
	acct-user/sonarqube
"
RDEPEND="
	acct-group/sonarqube
	acct-user/sonarqube
	dev-java/java-config
	|| (
		virtual/jdk:25
		virtual/jdk:21
	)
"

QA_PREBUILT="opt/sonarqube/elasticsearch/lib/platform/linux-*/lib*.so"

src_prepare() {
	default

	# The upstream Linux launcher is architecture-independent despite its
	# directory name.
	mv bin/linux-x86-64 bin/linux || die
	rm -r bin/macosx-universal-64 bin/windows-x86-64 bin/winsw-license || die

	rm -r \
		elasticsearch/lib/platform/darwin-aarch64 \
		elasticsearch/lib/platform/darwin-x64 \
		elasticsearch/lib/platform/windows-x64 || die
	case ${ARCH} in
		amd64)
			rm -r elasticsearch/lib/platform/linux-aarch64 || die
			;;
		arm64)
			rm -r elasticsearch/lib/platform/linux-x64 || die
			;;
		*)
			die "Unsupported architecture: ${ARCH}"
			;;
	esac

	find elasticsearch -type f \( -name '*.bat' -o -name '*.exe' \) \
		-delete || die
}

src_install() {
	local install_dir=/opt/sonarqube

	# Keep configuration and mutable state outside the versioned application
	# payload while retaining the paths expected by SonarQube.
	mv conf extensions "${T}" || die
	rm -r data logs temp || die

	dodir "${install_dir}"
	cp -pPR . "${ED}${install_dir}/" || die
	fowners -R root:root "${install_dir}"

	insinto /etc/sonarqube
	doins "${T}"/conf/sonar.properties

	insinto /var/lib/sonarqube/extensions
	doins -r "${T}"/extensions/.

	keepdir \
		/var/lib/sonarqube/data \
		/var/lib/sonarqube/temp \
		/var/log/sonarqube

	dosym -r /etc/sonarqube "${install_dir}"/conf
	dosym -r /var/lib/sonarqube/data "${install_dir}"/data
	dosym -r /var/lib/sonarqube/extensions "${install_dir}"/extensions
	dosym -r /var/log/sonarqube "${install_dir}"/logs
	dosym -r /var/lib/sonarqube/temp "${install_dir}"/temp

	newconfd "${FILESDIR}"/sonarqube.confd sonarqube
	newinitd "${FILESDIR}"/sonarqube.initd sonarqube
	systemd_dounit "${FILESDIR}"/sonarqube.service

	exeinto /usr/libexec/sonarqube
	newexe "${FILESDIR}"/sonarqube-launcher sonarqube-launcher

	insinto /etc/sysctl.d
	newins "${FILESDIR}"/sonarqube.sysctl 90-sonarqube.conf

	fowners -R root:sonarqube /etc/sonarqube
	fperms 0750 /etc/sonarqube
	fperms 0640 /etc/sonarqube/sonar.properties

	fowners -R sonarqube:sonarqube \
		/var/lib/sonarqube \
		/var/log/sonarqube
	fperms 0750 \
		/var/lib/sonarqube \
		/var/lib/sonarqube/data \
		/var/lib/sonarqube/extensions \
		/var/lib/sonarqube/temp \
		/var/log/sonarqube
}

pkg_postinst() {
	elog "Configure SonarQube in /etc/sonarqube/sonar.properties."
	elog "The embedded H2 database is for testing only; configure a supported"
	elog "external database before using this installation in production."
	elog
	elog "SonarQube requires JDK 21 or JDK 25. The service automatically selects"
	elog "a supported Gentoo-managed JDK. To override it, set SONAR_JAVA_PATH in"
	elog "/etc/conf.d/sonarqube to the full path of a supported java executable."
	elog
	elog "The installed /etc/sysctl.d/90-sonarqube.conf sets vm.max_map_count"
	elog "to the required minimum of 524288. Load it before starting SonarQube:"
	elog "  sysctl -p /etc/sysctl.d/90-sonarqube.conf"
	elog "Alternatively, reboot. The service also checks that fs.file-max is at"
	elog "least 131072. This package does not change that host-wide limit; adjust"
	elog "fs.file-max manually only when its current value is below 131072."
	elog
	ewarn "Do not upgrade an old SonarQube installation directly to this release."
	ewarn "Back up the database and follow the upstream upgrade procedure:"
	ewarn "https://docs.sonarsource.com/sonarqube-community-build/server-update-and-maintenance/update/"
}
