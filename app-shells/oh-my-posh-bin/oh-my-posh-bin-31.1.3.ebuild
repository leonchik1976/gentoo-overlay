# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Prompt theme engine for any shell, packaged from upstream prebuilt binaries"
HOMEPAGE="https://ohmyposh.dev/ https://github.com/JanDeDobbeleer/oh-my-posh"
SRC_URI="
	amd64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-arm64 -> ${P}-linux-arm64 )
	https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/themes.zip -> ${P}-themes.zip
"
S="${WORKDIR}"

# oh-my-posh itself: MIT. As a Go binary it also statically embeds all of
# its compiled-in dependencies' code, so LICENSE must cover those too, not
# just the top-level project. Determined by running `go list -deps` for
# the actual `main` package (not `./...`, which pulls in test-only helper
# packages and their own extra dependencies that never end up in the
# shipped binary) against upstream's own release-goreleaser build tags
# (netgo, osusergo, static_build, timetzdata; CGO_ENABLED=0) for both
# linux/amd64 and linux/arm64 -- both produce the same 30-module set. Every
# module's actual shipped LICENSE/COPYING file was read directly (not
# inferred from SPDX/API metadata); see files/NOTICE.deps.txt for the full
# per-module table and methodology. All 30 are MIT, Apache-2.0, or BSD
# (2- or 3-clause); none are copyleft. go.yaml.in/yaml/v3 is genuinely
# split by file between MIT (libyaml-ported files) and Apache-2.0 (the
# rest, per its own NOTICE file) -- both identifiers are already covered
# below, so this needs no separate entry. Gentoo's licenses/ tree has no
# "BSD-3" identifier: plain "BSD" is the 3-clause text, "BSD-2" the
# 2-clause text (both verified against the actual license files).
LICENSE="MIT Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/oh-my-posh"

src_unpack() {
	# The arch binary is a bare ELF with no recognized archive extension;
	# default src_unpack's `unpack` helper does not copy such files into
	# ${WORKDIR} at all, so pull it from ${DISTDIR} explicitly. Only
	# themes.zip needs actual extraction.
	unpack "${P}-themes.zip"
}

src_install() {
	local upstream_arch
	case ${ARCH} in
		amd64) upstream_arch=amd64 ;;
		arm64) upstream_arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "${DISTDIR}/${P}-linux-${upstream_arch}" oh-my-posh

	# themes.zip has no top-level directory, so its contents land directly
	# in ${WORKDIR}; glob by extension only. Most themes are .omp.json,
	# but a few (e.g. devious-diamonds, glowsticks) ship as .omp.yaml.
	insinto /usr/share/oh-my-posh/themes
	doins *.omp.json *.omp.yaml

	dodoc "${FILESDIR}"/NOTICE.deps.txt

	# go.yaml.in/yaml/v3 (the compiled-in YAML module; formerly Canonical's
	# go-yaml, still copyright Canonical Ltd. per its own NOTICE) is
	# Apache-2.0 for the non-libyaml-ported files -- see NOTICE.deps.txt.
	# Apache-2.0 section 4(d) requires any NOTICE text a work distributes to be
	# preserved in redistributions; ship the module's actual upstream
	# NOTICE file verbatim rather than only summarizing its contents.
	newdoc "${FILESDIR}"/go.yaml.in-yaml-v3.NOTICE NOTICE.go.yaml.in-yaml-v3
}
