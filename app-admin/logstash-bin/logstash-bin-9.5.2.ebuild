# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN%-bin}"
MY_P="${MY_PN}-${PV}"

# Only vendor/jruby/lib/ruby/stdlib/libfixposix/binary/<platform>/libfixposix.*
# is a genuinely arch-specific prebuilt binary; map ARCH to its directory
# name so src_prepare and QA_PREBUILT only ever reference the one we keep.
LS_LIBFIXPOSIX_PLATFORM="${ARCH/amd64/x86_64}-linux"

DESCRIPTION="Tool for managing events and logs"
HOMEPAGE="https://www.elastic.co/products/logstash"
SRC_URI="
	x-pack? (
		amd64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_P}-linux-x86_64.tar.gz )
		arm64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_P}-linux-aarch64.tar.gz )
	)
	!x-pack? (
		amd64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_PN}-oss-${PV}-linux-x86_64.tar.gz )
		arm64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_PN}-oss-${PV}-linux-aarch64.tar.gz )
	)
"
S="${WORKDIR}/${MY_P}"

# source: LICENSE.txt and NOTICE.TXT
LICENSE="Apache-2.0 BSD BSD-2 EPL-2.0 GPL-2 ISC LGPL-2.1+ MIT MPL-2.0 Ruby public-domain x-pack? ( Elastic )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="x-pack"
RESTRICT="bindist mirror strip"

QA_PREBUILT="opt/logstash/vendor/jruby/lib/ruby/stdlib/libfixposix/binary/${LS_LIBFIXPOSIX_PLATFORM}/libfixposix.so"

RDEPEND="
	acct-group/logstash
	acct-user/logstash
	sys-libs/glibc
	>=virtual/jre-21
"

src_prepare() {
	default

	rm vendor/jruby/bin/jruby.dll || die

	# JRuby no longer bundles libjffi for every platform (unlike 7.x); only
	# vendor/jruby/lib/ruby/stdlib/libfixposix/binary/<platform>/libfixposix.*
	# remains. Drop every platform except the one matching ARCH.
	local d
	for d in vendor/jruby/lib/ruby/stdlib/libfixposix/binary/*/; do
		d="${d%/}"
		[[ "${d##*/}" == "${LS_LIBFIXPOSIX_PLATFORM}" ]] && continue
		rm -r "${d}" || die
	done

	# remove bundled JDK, use system JRE
	rm -r jdk || die
}

src_install() {
	keepdir /etc/"${MY_PN}"/{conf.d,patterns,plugins}
	keepdir "/var/log/${MY_PN}"

	insinto "/usr/share/${MY_PN}"
	newins "${FILESDIR}/agent.conf.sample" agent.conf

	rm -v config/{pipelines.yml,startup.options} || die
	insinto /etc/${MY_PN}
	doins -r config/.
	doins "${FILESDIR}/pipelines.yml"
	rm -rv config data || die

	insinto "/opt/${MY_PN}"
	doins -r .
	fperms 0755 "/opt/${MY_PN}/bin/${MY_PN}" "/opt/${MY_PN}/vendor/jruby/bin/jruby" "/opt/${MY_PN}/bin/logstash-plugin"

	newconfd "${FILESDIR}/${MY_PN}.confd-r2" "${MY_PN}"
	newinitd "${FILESDIR}/${MY_PN}.initd-r2" "${MY_PN}"

	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/logstash-plugin.eselect
}

pkg_postinst() {
	ewarn "Self installed plugins are removed during Logstash upgrades (Bug #622602)"
	ewarn "Install the plugins via eselect module that will automatically re-install"
	ewarn "all self installed plugins after Logstash upgrades."
	elog
	elog "Installing plugins:"
	elog "eselect logstash-plugin install logstash-output-gelf"
	elog

	elog "Reinstalling self installed plugins (installed via eselect module):"
	eselect logstash-plugin reinstall

	elog
	elog "Sample configuration:"
	elog "${EROOT}/usr/share/${MY_PN}"
	elog
	elog "The default pipeline configuration expects the configuration(s) to be found in:"
	elog "${EROOT}/etc/logstash/conf.d/*.conf"
}
