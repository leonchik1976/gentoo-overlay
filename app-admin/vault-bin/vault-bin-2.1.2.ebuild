# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# fcaps and systemd currently support EAPI 7 and 8 only.
EAPI=8

inherit fcaps systemd

DESCRIPTION="A tool for managing secrets (upstream binaries)"
HOMEPAGE="https://developer.hashicorp.com/vault https://github.com/hashicorp/vault"
SRC_URI="
	amd64? ( https://releases.hashicorp.com/vault/${PV}/vault_${PV}_linux_amd64.zip )
	arm64? ( https://releases.hashicorp.com/vault/${PV}/vault_${PV}_linux_arm64.zip )
"
S="${WORKDIR}"

# Include the statically linked modules and embedded web UI/font licenses.
LICENSE="Apache-2.0 BSD BSD-2 BUSL-1.1 ISC MIT MPL-2.0 OFL-1.1 Unicode-DFS-2016 UPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	acct-group/vault
	acct-user/vault
"
RDEPEND="${DEPEND}
	!app-admin/vault
"
BDEPEND+=" app-arch/unzip"

RESTRICT="strip"
QA_PREBUILT="usr/bin/vault"

FILECAPS=(
	-m 755 'cap_ipc_lock=+ep' usr/bin/vault
)

# Upstream embeds the web UI; it cannot be disabled at installation time.
src_test() {
	./vault version || die
	./vault -help >/dev/null || die
}

src_install() {
	dobin vault
	dodoc LICENSE.txt

	insinto /etc/vault.d
	doins "${FILESDIR}/localhost.json.example"
	insinto /etc/logrotate.d
	newins "${FILESDIR}/vault.logrotated" vault
	newinitd "${FILESDIR}/vault.initd" vault
	newconfd "${FILESDIR}/vault.confd" vault
	systemd_dounit "${FILESDIR}/vault.service"
	keepdir /var/log/vault
	fowners vault:vault /var/log/vault
}
