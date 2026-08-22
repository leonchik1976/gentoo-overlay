# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion toolchain-funcs

MY_PN="${PN%-bin}"

DESCRIPTION="Dev tools, env vars, and tasks in one CLI"
HOMEPAGE="https://mise.jdx.dev https://github.com/jdx/mise"
SRC_URI="
	amd64? (
		https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/${MY_PN}"

LICENSE="MIT"
# Licenses of crates statically linked into the release binary (derived from
# the exact Cargo.lock at v${PV}; see the dev-util/mise-bin metadata for how
# this was verified).
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-1 BSD-2 BZIP2
	Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 GPL-2 ISC LGPL-2.1 LGPL-3 MIT-0
	MPL-2.0 Unicode-3.0 Unlicense ZLIB openssl
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

# The release binary is dynamically linked only against glibc and libgcc_s
# (verified via readelf -d); openssl/zstd/xz are statically embedded, so no
# equivalent of the source build's BDEPEND applies here.
#
# All three generated shell completions (bash, zsh, fish) shell out to a
# separate "usage" binary at completion time -- confirmed by running each
# generated script and finding "type -p usage" guards plus a
# "command usage complete-word ..." call in every one of them, not just the
# bash/fish stubs. mise's embedded spec also declares
# min_usage_version "4.0", hence the version bound below.
RDEPEND="
	>=dev-util/usage-bin-4.0
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	elibc_glibc? ( sys-libs/glibc )
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_compile() {
	# mise generates completions from its own embedded CLI definitions; this
	# touches no network and, under Portage's sandboxed HOME, no real user
	# configuration. All three scripts call out to a separate "usage" binary
	# at completion time (dev-util/usage-bin, pulled in via RDEPEND) -- this
	# is not just a bash/fish quirk, zsh does it too.
	if ! tc-is-cross-compiler; then
		./bin/"${MY_PN}" completion bash > "${T}/${MY_PN}" || die
		./bin/"${MY_PN}" completion fish > "${T}/${MY_PN}.fish" || die
		./bin/"${MY_PN}" completion zsh > "${T}/_${MY_PN}" || die
	else
		ewarn "shell completion files were skipped due to cross-compilation"
	fi
}

src_install() {
	dobin bin/"${MY_PN}"

	doman man/man1/"${MY_PN}".1

	if ! tc-is-cross-compiler; then
		dobashcomp "${T}/${MY_PN}"
		dofishcomp "${T}/${MY_PN}.fish"
		dozshcomp "${T}/_${MY_PN}"
	fi

	insinto /usr/share/fish/vendor_conf.d
	doins share/fish/vendor_conf.d/"${MY_PN}"-activate.fish

	einstalldocs
}

pkg_postinst() {
	elog "bash, zsh, and fish completions all call dev-util/usage-bin at"
	elog "completion time; it is pulled in automatically via RDEPEND."
}
