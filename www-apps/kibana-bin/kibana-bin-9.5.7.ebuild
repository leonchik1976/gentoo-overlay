# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN="${PN%-bin}"
MY_P="${MY_PN}-${PV}"

# Chromium (used for PDF/PNG reporting) ships one prebuilt headless_shell
# directory per arch; map ARCH to its suffix (x64 on amd64, arm64 on arm64).
MY_CHROMIUM_ARCH="${ARCH/amd64/x64}"
MY_CHROMIUM_DIR="node_modules/@kbn/screenshotting-plugin/chromium/headless_shell-linux_${MY_CHROMIUM_ARCH}"

DESCRIPTION="Analytics and search dashboard for Elasticsearch"
HOMEPAGE="https://www.elastic.co/products/kibana"
SRC_URI="
	amd64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_P}-linux-x86_64.tar.gz )
	arm64? ( https://artifacts.elastic.co/downloads/${MY_PN}/${MY_P}-linux-aarch64.tar.gz )
"
S="${WORKDIR}/${MY_P}"

# source: LICENSE.txt and NOTICE.txt
LICENSE="0BSD Apache-2.0 Artistic-2 BSD BSD-2 BlueOak-1.0.0 CC-BY-SA-4.0 Elastic-2.0 ISC MIT MPL-2.0 PYTHON Unlicense WTFPL-2 ZLIB icu public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

BDEPEND+="
	acct-group/kibana
	acct-user/kibana
"
RDEPEND="
	acct-group/kibana
	acct-user/kibana
	dev-libs/expat
	dev-libs/nspr
	dev-libs/nss
	sys-libs/glibc
"

QA_PREBUILT="
	opt/kibana/node/glibc-217/bin/node
	opt/kibana/${MY_CHROMIUM_DIR}/headless_shell
	opt/kibana/${MY_CHROMIUM_DIR}/libEGL.so
	opt/kibana/${MY_CHROMIUM_DIR}/libGLESv2.so
	opt/kibana/${MY_CHROMIUM_DIR}/libvk_swiftshader.so
	opt/kibana/${MY_CHROMIUM_DIR}/libvulkan.so.1
"

src_prepare() {
	default

	# remove unused directories (empty markers in the upstream tarball)
	rm -r data logs || die

	# move plugins to /var/lib/kibana
	rm -r plugins || die
}

src_install() {
	insinto /etc/${MY_PN}
	doins -r config/.
	rm -r config || die

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${MY_PN}.logrotate ${MY_PN}

	newconfd "${FILESDIR}"/${MY_PN}.confd ${MY_PN}
	newinitd "${FILESDIR}"/${MY_PN}.initd-r1 ${MY_PN}
	systemd_dounit "${FILESDIR}"/${MY_PN}.service

	insinto /opt/${MY_PN}
	doins -r .

	fperms -R +x /opt/${MY_PN}/bin
	fperms +x /opt/${MY_PN}/node/glibc-217/bin/node
	fperms +x "/opt/${MY_PN}/${MY_CHROMIUM_DIR}/headless_shell"

	diropts -m 0750 -o ${MY_PN} -g ${MY_PN}
	keepdir /var/lib/${MY_PN}/plugins
	keepdir /var/log/${MY_PN}

	dosym ../../var/lib/kibana/plugins /opt/kibana/plugins
	dosym ../../etc/kibana /opt/kibana/config
}

pkg_postinst() {
	elog "This version of Kibana is compatible with Elasticsearch $(ver_cut 1-2)."
	elog "Unlike older kibana-bin versions, the bundled Node.js runtime is kept"
	elog "in place rather than replaced with net-libs/nodejs: Kibana 9.x pins an"
	elog "exact Node.js version and several /opt/kibana/bin/* helper scripts"
	elog "hardcode the bundled node path (see bug #953804)."
	elog
	elog "To set a customized Elasticsearch instance:"
	elog "  OpenRC: set ES_INSTANCE in /etc/conf.d/${MY_PN}"
	elog "  systemd: set elasticsearch.url in /etc/${MY_PN}/kibana.yml"
	elog
	elog "Elasticsearch can run local or remote."
}
