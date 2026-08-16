# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=""
RUST_MIN_VER="1.96.0"
inherit cargo

DESCRIPTION="pgrx: A Rust framework for creating Postgres extensions"
HOMEPAGE="https://github.com/pgcentralfoundation/pgrx/"

MY_PV="${PV/alpha/alpha.}"
MY_PV="${MY_PV/_/-}"
SRC_URI="
	https://github.com/pgcentralfoundation/pgrx/archive/refs/tags/v${MY_PV}.tar.gz -> pgrx-${PV}.tar.gz
"
SRC_URI+=" https://github.com/gentoo-crate-dist/${PN#cargo-}/releases/download/v${PV}/${P#cargo-}-crates.tar.xz"

S=${WORKDIR}/pgrx-${MY_PV}/cargo-pgrx

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD BZIP2 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB"
# ring crate builds its own bundled crypto C/assembly regardless; this is
# not eliminable via a system dependency, so keep the license entry.
LICENSE+=" openssl"
SLOT="0"

KEYWORDS="~amd64 ~arm64"

RESTRICT="test" # needs custom setup

# Use Gentoo's system zstd instead of letting the zstd-sys crate compile
# its bundled copy of the zstd C sources.
export ZSTD_SYS_USE_PKG_CONFIG=1

DEPEND="
	app-arch/zstd:=
	dev-libs/openssl:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_unpack() {
	cargo_src_unpack
	mkdir -p "${WORKDIR}"/pgrx-${PV}/.pgrx
	export PGRX_HOME="${WORKDIR}"/pgrx-${PV}/.pgrx
}
