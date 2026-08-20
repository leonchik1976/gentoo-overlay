# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="TUI implementation of the classic Battleship game (prebuilt AOT binary)"
HOMEPAGE="https://github.com/reflectd/Battleship-TUI"
SRC_URI="
	amd64? (
		https://github.com/reflectd/Battleship-TUI/releases/download/v${PV}/battleship-linux-x64
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/reflectd/Battleship-TUI/releases/download/v${PV}/battleship-linux-arm64
			-> ${P}-arm64
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

# Both release binaries require versioned glibc symbols through GLIBC_2.34.
# This intentionally makes the package unavailable on musl profiles.
RDEPEND=">=sys-libs/glibc-2.34"

# Upstream publishes self-contained NativeAOT binaries for both supported
# architectures; dotnet-pkg.eclass normally builds framework-dependent output.
QA_PREBUILT="usr/bin/battleship-tui"

src_unpack() {
	:
}

src_install() {
	local source

	case ${ARCH} in
		amd64)
			source="${DISTDIR}/${P}-amd64"
			;;
		arm64)
			source="${DISTDIR}/${P}-arm64"
			;;
		*)
			die "Unsupported architecture: ${ARCH}"
			;;
	esac

	newbin "${source}" battleship-tui
}
