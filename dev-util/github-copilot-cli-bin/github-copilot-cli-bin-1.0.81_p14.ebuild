# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=copilot
MY_PV=${PV/_p/-}

DESCRIPTION="GitHub Copilot coding agent, brought directly to your terminal"
HOMEPAGE="
	https://github.com/features/copilot/cli
	https://github.com/github/copilot-cli
"

# Each per-arch release asset is a flat tar.gz containing exactly one file:
# a single self-contained ~110-170MB stripped ELF executable named
# "copilot" (verified via `tar tzf`/`file`/`readelf -d` on both the
# linux-x64 and linux-arm64 v1.0.81-6 assets). It links only libdl,
# libstdc++, libm, libgcc_s, libpthread, libc, and ld-linux -- no GTK/X11/
# Electron stack, unlike the desktop app in app-editors/github-copilot-bin.
GH_BASE_URI="https://github.com/github/copilot-cli/releases/download/v${MY_PV}"
SRC_URI="
	amd64? ( ${GH_BASE_URI}/copilot-linux-x64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( ${GH_BASE_URI}/copilot-linux-arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

# github/copilot-cli is a release-only repository (LICENSE.md, README,
# install.sh, changelog -- no source); this is a closed-source, prebuilt
# distribution. LICENSE.md's own terms only permit redistributing the
# Software "as part of an application or service that provides material
# functionality beyond the Software itself" and explicitly forbid
# standalone/primary-product distribution (see licenses/GitHub-Copilot-CLI).
# As with every other proprietary package in this overlay, no binary is
# rehosted: RESTRICT=mirror/bindist keep Portage's own infrastructure from
# redistributing it, and the ebuild only ever fetches directly from
# GitHub's own release URL at build time -- but that "material functionality
# beyond the Software itself" clause is in real tension with an ebuild
# whose entire purpose is delivering this CLI as the primary installed
# product. This has not been resolved with GitHub; treat it as a known,
# unresolved licensing caveat of packaging this tool at all, not merely a
# distribution-mechanics detail.
LICENSE="GitHub-Copilot-CLI"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# libstdc++ (linked, per readelf -d) is provided by the always-present
# system toolchain (sys-devel/gcc, part of @system) and is intentionally
# not listed here, matching established practice for other prebuilt Gentoo
# binaries (see e.g. sci-libs/aotriton-bin).
RDEPEND="sys-libs/glibc"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	newbin ${MY_PN} ${MY_PN}
}
