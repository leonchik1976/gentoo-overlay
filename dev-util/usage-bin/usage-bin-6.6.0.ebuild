# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="${PN%-bin}"

DESCRIPTION="A specification for defining CLIs"
HOMEPAGE="https://usage.jdx.dev https://github.com/jdx/usage"
SRC_URI="
	amd64? (
		https://github.com/jdx/usage/releases/download/v${PV}/usage-x86_64-unknown-linux-gnu.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/jdx/usage/releases/download/v${PV}/usage-aarch64-unknown-linux-gnu.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/normalized"

LICENSE="MIT"
# Licenses of crates statically linked into the release binary (derived from
# the exact v${PV} Cargo.lock and Cargo metadata, filtered from usage-cli over
# non-dev normal/build edges for each Linux release target). Both
# x86_64-unknown-linux-gnu and aarch64-unknown-linux-gnu resolve to the same
# 126 package instances / 118 unique package names and the same license set.
# The complete lockfile has 258 package instances / 244 unique names, but its
# unrelated workspace benchmarks, tests, and target-specific packages are not
# linked into either shipped binary and therefore are not included here.
LICENSE+="
	Apache-2.0 Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

# Both v${PV} release binaries were inspected with file(1) and readelf(1).
# amd64 needs libc, libm, libdl, libpthread, librt, and libgcc_s; arm64 needs
# the same set except librt. The glibc libraries are satisfied by
# sys-libs/glibc; libgcc_s.so.1 is satisfied separately by
# llvm-runtimes/libgcc or sys-devel/gcc, hence the || ( ) block below. No
# other statically-embedded dependency links to a system library at runtime.
RDEPEND="
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	elibc_glibc? ( sys-libs/glibc )
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_unpack() {
	default

	mkdir "${S}" || die
	cp --no-preserve=ownership -- "${WORKDIR}/${MY_PN}" "${S}" || die
	cp --no-preserve=ownership -- "${WORKDIR}/${MY_PN}.1" "${S}" || die
}

src_install() {
	dobin "${MY_PN}"

	doman "${MY_PN}".1
}
