# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Run kubectl in a browser-based terminal"
HOMEPAGE="https://github.com/1Panel-dev/webkubectl"
SRC_URI="
	https://github.com/1Panel-dev/webkubectl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/leonchik1976/gentoo-overlay/releases/download/distfiles/${P}-deps.tar.xz
"

S="${WORKDIR}/${P}/gotty"

# webkubectl itself (the wrapper scripts, adapted from upstream's own
# Apache-2.0-licensed start-webkubectl.sh/start-session.sh/
# init-kubectl.sh) is Apache-2.0, verified against this exact
# release's own top-level LICENSE file. The bundled gotty fork is
# MIT (its own gotty/LICENSE, Copyright (c) 2015-2017 Iwasaki Yudai).
#
# The remaining LICENSE entries were re-derived from dev-go/lichen
# run against the actual, offline-built gotty binary (not merely from
# go.sum, which lists many additional modules go-module.eclass's own
# GOFLAGS=-mod=mod build never actually links -- confirmed directly:
# `go version -m` on the built binary lists exactly the same 13
# dependency modules lichen found, e.g. golang.org/x/sys is an
# indirect go.mod requirement that is not actually linked). Of those
# 13: github.com/NYTimes/gziphandler is Apache-2.0; seven
# (cespare/xxhash/v2, cpuguy83/go-md2man/v2, creack/pty,
# dgryski/go-rendezvous, fatih/structs, patrickmn/go-cache,
# urfave/cli/v2) are MIT; five (elazarl/go-bindata-assetfs,
# go-redis/redis/v8, gorilla/websocket, pkg/errors,
# russross/blackfriday/v2) are BSD-2-Clause -- each verified directly
# against its own LICENSE file in the dependency cache, all
# genuine 2-clause texts (no third "endorse or promote" clause), none
# BSD-3-Clause. The previous "BSD" (generic 3-clause) entry is
# removed: no linked module's actual license text matches it.
LICENSE="Apache-2.0 BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	sys-apps/util-linux
	sys-cluster/kubectl
"

BDEPEND+=" >=dev-lang/go-1.18"

# Upstream's own test suite is not present in this vendored gotty
# fork's release tag in a runnable form.
RESTRICT="test"

src_compile() {
	local -x CGO_ENABLED=0
	local go_ldflags="-X main.Version=${PV}"

	ego build -trimpath -ldflags "${go_ldflags}" -o gotty .
}

src_install() {
	dobin gotty

	exeinto /usr/libexec/webkubectl
	doexe "${FILESDIR}"/start-webkubectl.sh
	doexe "${FILESDIR}"/start-session.sh
	doexe "${FILESDIR}"/init-kubectl.sh

	dodoc "${WORKDIR}"/${P}/README.md

	systemd_newunit "${FILESDIR}"/webkubectl.service webkubectl.service

	# Per-session tmpfs mountpoints (see init-kubectl.sh) are created
	# here rather than under a shared, predictable root-level path.
	# 0711 (traversal-only, no listing): each session's own mountpoint
	# is chowned/chmoded 0700 nobody:nogroup by init-kubectl.sh before
	# the "nobody" shell starts, so "nobody" needs to be able to reach
	# into that one entry without being able to list this directory's
	# other (other users') session names.
	diropts -m 0711
	keepdir /var/lib/webkubectl

	# Administrator-provided kubeconfig lives here (see
	# init-kubectl.sh); 0700 since the service itself runs as root and
	# reads it directly, and kubeconfigs commonly embed credentials.
	diropts -m 0700
	keepdir /etc/webkubectl
}
