# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Horizontally scalable, highly available, multi-tenant, long term Prometheus"
HOMEPAGE="https://cortexmetrics.io/ https://github.com/cortexproject/cortex"
SRC_URI="https://github.com/cortexproject/cortex/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Aggregate of the licenses of Cortex itself and all vendored Go
# dependencies shipped in the upstream release tarball's vendor/
# directory (Cortex vendors its dependencies, so no separate module
# mirror or EGO_SUM is required).
LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_DEPEND="
	acct-group/cortex
	acct-user/cortex
"
RDEPEND="${ACCT_DEPEND}"

BDEPEND+=" >=dev-lang/go-1.25.0"

# The upstream test suite depends on external services (etcd, consul,
# S3-compatible object storage, etc.) that are not available in the
# Gentoo build sandbox.
RESTRICT="test"

src_compile() {
	local -x CGO_ENABLED=0
	local go_ldflags="-X main.Branch=HEAD -X main.Revision=v${PV} -X main.Version=${PV}"

	ego build -mod=vendor -trimpath -tags "netgo slicelabels" \
		-ldflags "${go_ldflags}" -o bin/cortex ./cmd/cortex
}

src_install() {
	dobin bin/cortex

	dodoc README.md CHANGELOG.md
	docinto examples
	dodoc docs/configuration/single-process-config-blocks*.yaml

	# Upstream's example config hardcodes /tmp/cortex/* for every
	# storage backend (TSDB, compactor, ruler, alertmanager) -- fine
	# for its stated "single process, local development" purpose, but
	# not a sensible default for a persistent service under this
	# ebuild's PrivateTmp=true unit. Point it at the persistent data
	# directory instead. Verified by actually starting the service:
	# without this, the ruler and alertmanager modules fail
	# ("no such file or directory") and the process never becomes
	# ready.
	sed -e 's#/tmp/cortex#/var/lib/cortex#g' \
		docs/configuration/single-process-config-blocks-local.yaml \
		> "${T}"/config.yaml || die
	insinto /etc/cortex
	doins "${T}"/config.yaml

	systemd_newunit "${FILESDIR}"/cortex.service cortex.service

	keepdir /var/lib/cortex
	# ruler.rule-path (cortex's own internal default: the top-level
	# /rules) and the storage directories the example config points
	# into /var/lib/cortex/ above are not auto-created by cortex on
	# first run for reading (only for writing new blocks) -- verified
	# by an actual start attempt failing on "unable to read dir".
	keepdir /var/lib/cortex/tsdb /var/lib/cortex/tsdb-sync
	keepdir /var/lib/cortex/compactor /var/lib/cortex/rules
	keepdir /var/lib/cortex/alerts /var/lib/cortex/rule-tmp
	fowners -R cortex:cortex /var/lib/cortex
}
