# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Horizontally scalable, highly available log aggregation system"
HOMEPAGE="https://grafana.com/oss/loki/ https://github.com/grafana/loki"
SRC_URI="https://github.com/grafana/loki/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Aggregate of Loki's own license and its statically linked Go dependencies.
# Upstream ships vendor/, so no separate dependency tarball is required.
LICENSE="AGPL-3 Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/loki
	acct-user/loki
"
RDEPEND="${ACCT_DEPEND}"

BDEPEND+=" >=dev-lang/go-1.26.10"

# The upstream test suite depends on external services (object
# storage emulators, etc.) that are not available in the Gentoo
# build sandbox.
RESTRICT="test"

src_compile() {
	local -x CGO_ENABLED=0
	local vprefix="github.com/grafana/loki/v3/pkg/util/build"
	local go_ldflags="-X ${vprefix}.Branch=HEAD -X ${vprefix}.Version=${PV}"
	go_ldflags+=" -X ${vprefix}.Revision=v${PV}"

	ego build -buildvcs=false -mod=vendor -trimpath -tags netgo \
		-ldflags "${go_ldflags}" -o bin/loki ./cmd/loki
	ego build -buildvcs=false -mod=vendor -trimpath -tags netgo \
		-ldflags "${go_ldflags}" -o bin/logcli ./cmd/logcli
}

src_install() {
	dobin bin/loki bin/logcli

	dodoc README.md CHANGELOG.md LICENSE

	# Preserve the notices accompanying statically linked vendored code.
	local notice
	while IFS= read -r -d '' notice; do
		docinto "licenses/${notice%/*}"
		dodoc "${notice}"
	done < <(find vendor -type f \( -iname 'license*' -o -iname 'copying*' \
		-o -iname 'notice*' -o -iname 'copyright*' \) \
		! -name '*.go' ! -name 'LICENSE.docs' ! -name 'LICENSE-LOGO' -print0)

	insinto /etc/loki
	newins cmd/loki/loki-local-config.yaml config.yaml

	systemd_newunit "${FILESDIR}"/loki.service loki.service

	keepdir /var/lib/loki
	fowners loki:loki /var/lib/loki
}
