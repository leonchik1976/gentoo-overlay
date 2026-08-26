# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN="boundary"

DESCRIPTION="Identity-based access management for dynamic infrastructure"
HOMEPAGE="https://www.boundaryproject.io/ https://github.com/hashicorp/boundary"
SRC_URI="
	amd64? (
		https://releases.hashicorp.com/boundary/${PV}/${MY_PN}_${PV}_linux_amd64.zip
			-> ${P}-amd64.zip
	)
	arm64? (
		https://releases.hashicorp.com/boundary/${PV}/${MY_PN}_${PV}_linux_arm64.zip
			-> ${P}-arm64.zip
	)
"
S="${WORKDIR}"

# PARTIAL LICENSE AUDIT: only the top-level LICENSE.txt was checked;
# the 181 compiled-in Go dependency modules named via `go version -m`
# (see below) were not individually license-verified. Not a complete
# audit of every bundled component.
#
# Verified against this exact release's own LICENSE.txt: BUSL-1.1,
# NOT an open-source license (source-available; internal production
# use is permitted under the Additional Use Grant, but it does not
# meet the OSI/FSF free-software definition). Converts to MPL-2.0
# four years after this version's publication date (2026-04-30), per
# the Change Date/Change License clauses in that same LICENSE.txt.
#
# Built from source is not practical here: the release has no
# vendor/ directory (743-line go.sum would be required via EGO_SUM),
# and more importantly the admin UI is embedded from a build of the
# separate hashicorp/boundary-ui (Ember.js) repository via go:embed
# in internal/ui/assets.go, which is not solvable through
# go-module.eclass at all.
# This is a statically-linked Go binary, not a JVM archive: it
# embeds no per-dependency license text extractable from the
# distributed artifact, unlike this overlay's Java-based binary
# packages. `go version -m` against the actual shipped binary (fully
# offline, reads Go's own embedded build-info blob) confirms exactly
# 181 compiled-in dependency modules by name and pinned version, but
# Go does not embed their license text -- verifying each would
# require network access to every one of those 181 upstream
# repositories, which was not performed. Not enumerated here rather
# than guessed at from module names.
LICENSE="BUSL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

ACCT_DEPEND="
	acct-group/boundary
	acct-user/boundary
"
RDEPEND="${ACCT_DEPEND}"
BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/boundary"

src_install() {
	dobin boundary
	dodoc LICENSE.txt

	systemd_newunit "${FILESDIR}"/boundary.service boundary.service

	keepdir /var/lib/boundary
	fowners boundary:boundary /var/lib/boundary
}
