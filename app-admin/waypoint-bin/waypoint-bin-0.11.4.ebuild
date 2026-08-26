# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="waypoint"

DESCRIPTION="Build, deploy, and release tool for any platform (upstream archived)"
HOMEPAGE="https://github.com/hashicorp/waypoint"
SRC_URI="
	amd64? (
		https://releases.hashicorp.com/waypoint/${PV}/${MY_PN}_${PV}_linux_amd64.zip
			-> ${P}-amd64.zip
	)
	arm64? (
		https://releases.hashicorp.com/waypoint/${PV}/${MY_PN}_${PV}_linux_arm64.zip
			-> ${P}-arm64.zip
	)
"
S="${WORKDIR}"

# PARTIAL LICENSE AUDIT: only the top-level LICENSE file was checked;
# the 327 compiled-in Go dependency modules named via `go version -m`
# (see below) were not individually license-verified. Not a complete
# audit of every bundled component.
#
# hashicorp/waypoint was archived upstream on 2024-01-08; v0.11.4
# (2023-08-09) is its final release and the last one still under
# MPL-2.0 -- verified against this exact tag's own LICENSE file,
# fetched separately since the release archive itself does not
# bundle one. It predates HashiCorp's 2023-08-10 BUSL-1.1 switch by
# one day, so no later, differently-licensed release exists to track.
#
# Packaged as -bin: the source release has no vendor/ directory and
# would need a ~3400-line EGO_SUM (larger even than Traefik's, which
# this overlay already treats as impractical for the same reason),
# and the project being archived means no maintainer will ever
# regenerate a proper dependency tarball for it.
# This is a statically-linked Go binary, not a JVM archive: it
# embeds no per-dependency license text extractable from the
# distributed artifact. `go version -m` against the actual shipped
# binary (fully offline, reads Go's own embedded build-info blob)
# confirms exactly 327 compiled-in dependency modules by name and
# pinned version, but Go does not embed their license text --
# verifying each would require network access to every one of those
# 327 upstream repositories, which was not performed. Not enumerated
# here rather than guessed at from module names.
LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/waypoint"

src_install() {
	dobin waypoint
}

pkg_postinst() {
	ewarn "hashicorp/waypoint was archived by upstream on 2024-01-08."
	ewarn "This is the final release (v0.11.4, 2023-08-09); it will"
	ewarn "receive no further updates or security fixes."
}
