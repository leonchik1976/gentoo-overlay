# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The lazier way to manage everything docker"
HOMEPAGE="https://github.com/jesseduffield/lazydocker"
SITE="https://github.com/jesseduffield/lazydocker/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/lazydocker_${PV}_Linux_x86_64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( ${SITE}/lazydocker_${PV}_Linux_arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own license
# plus every statically-linked dependency's license, audited directly
# against the compiled binary with dev-go/lichen: MIT (own + many),
# Apache-2.0 (docker/containerd/opentelemetry stack), BSD-3-Clause
# (-> BSD, e.g. golang.org/x/*, jesseduffield/gocui), BSD-2-Clause
# (-> BSD-2, pkg/errors), Unlicense (integrii/flaggy), and CC-BY-SA-4.0
# (one of the two licenses opencontainers/go-digest is offered under;
# Apache-2.0, already listed, is the other and is the one actually
# usable here).
#
# UNRESOLVED: github.com/boz/go-throttle (an indirect dependency, a
# ~50-line debounce/throttle helper) ships with NO LICENSE file at all
# in its upstream repository (confirmed directly against
# github.com/boz/go-throttle -- no LICENSE, no license mentioned in
# README, GitHub's own license detection reports none). This is a real,
# unresolved licensing gap inherited from upstream lazydocker itself
# (present in every official lazydocker release, not something specific
# to this packaging) -- not a placeholder or an omission on this
# ebuild's part. With no license grant, default copyright applies (no
# permission to redistribute), so this component is represented as
# all-rights-reserved below rather than silently omitted from LICENSE=
# or guessed at as permissively licensed. RESTRICT=bindist reflects the
# same constraint: this binary cannot be assumed freely redistributable.
LICENSE="MIT Apache-2.0 BSD BSD-2 Unlicense CC-BY-SA-4.0 all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="usr/bin/lazydocker"

src_install() {
	dobin lazydocker
	einstalldocs
}
