# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit flag-o-matic multiprocessing toolchain-funcs

DESCRIPTION="Fast git status daemon used by prompts such as powerlevel10k"
HOMEPAGE="https://github.com/romkatv/gitstatus"

# libgit2 is a build-time-only dependency: gitstatus vendors a patched fork
# and links it in statically (see build.info in ${S}). The pin below must
# match build.info for this exact gitstatus release.
LIBGIT2_COMMIT="tag-2ecf33948a4df9ef45a66c68b8ef24a5e60eaac6"

SRC_URI="
	https://github.com/romkatv/gitstatus/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/romkatv/libgit2/archive/${LIBGIT2_COMMIT}.tar.gz -> libgit2-${LIBGIT2_COMMIT}.tar.gz
"
S="${WORKDIR}/${P}"
LIBGIT2_S="${WORKDIR}/libgit2-${LIBGIT2_COMMIT}"

# gitstatus itself: GPL-3+.
# Vendored libgit2 fork, statically linked in: GPL-2-with-linking-exception.
# libgit2 in turn statically links in several of its own vendored
# dependencies, confirmed from actual configure output (REGEX_BACKEND=builtin
# means "libgit2's bundled PCRE", not a PCRE-free implementation):
# bundled zlib (ZLIB), bundled http-parser (MIT), bundled PCRE (BSD, per
# dev-libs/libpcre's own LICENSE in ::gentoo).
LICENSE="GPL-3+ GPL-2-with-linking-exception ZLIB MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-build/cmake
	test? ( dev-vcs/git )
"

src_configure() {
	# Reproduces the libgit2 half of upstream's ./build script (see
	# build.info / build), minus the parts that are irrelevant to an
	# ebuild: tool auto-installation, Docker cross-building, and
	# downloading the tarball at build time (we get it via SRC_URI).
	# Only the CMake feature flags are load-bearing here; gitstatusd
	# never performs network git operations, so SSH/HTTPS transports,
	# NTLM and GSSAPI auth are deliberately disabled upstream.
	cmake -S "${LIBGIT2_S}" -B "${LIBGIT2_S}/build" \
		-DCMAKE_BUILD_TYPE=None \
		-DZERO_NSEC=ON \
		-DTHREADSAFE=ON \
		-DUSE_BUNDLED_ZLIB=ON \
		-DREGEX_BACKEND=builtin \
		-DUSE_HTTP_PARSER=builtin \
		-DUSE_SSH=OFF \
		-DUSE_HTTPS=OFF \
		-DBUILD_CLAR=OFF \
		-DUSE_GSSAPI=OFF \
		-DUSE_NTLMCLIENT=OFF \
		-DBUILD_SHARED_LIBS=OFF \
		-DENABLE_REPRODUCIBLE_BUILDS=ON \
		|| die "cmake configure failed for vendored libgit2"
}

src_compile() {
	cmake --build "${LIBGIT2_S}/build" -j "$(get_makeopts_jobs)" || die "libgit2 build failed"

	# gitstatusd's own build is a plain Makefile (see ${S}/Makefile). It
	# only ever references $(CXXFLAGS), never $(CPPFLAGS), so the -I for
	# the vendored libgit2 fork's headers must be folded into CXXFLAGS
	# itself -- otherwise the compiler silently falls back to whatever
	# libgit2 happens to be installed system-wide, which does not declare
	# the same API this fork does and fails to build (this is the same
	# failure NixOS packagers hit: romkatv/gitstatus#7).
	#
	# Passing CXXFLAGS on the make command line (as emake does) also
	# fully overrides -- not appends to -- the Makefile's own
	# `CXXFLAGS += ...` line, including -DGITSTATUS_VERSION=$(VERSION);
	# without it, `gitstatusd --version` silently prints the literal
	# string "GITSTATUS_VERSION" instead of a real version. Define it
	# ourselves instead of relying on the Makefile's VERSION variable.
	#
	# We also link dynamically against the system libc (unlike upstream's
	# default fully-static release binaries, which exist to be portable
	# across distros); only libgit2 remains statically linked, which is
	# how upstream's build produces it regardless of the -static toggle.
	append-cxxflags -std=c++14 -funsigned-char -D_GNU_SOURCE \
		-DGITSTATUS_ZERO_NSEC -DGITSTATUS_VERSION="v${PV}" \
		-I"${LIBGIT2_S}/include"
	append-ldflags -L"${LIBGIT2_S}/build"

	emake \
		CXX="$(tc-getCXX)" \
		CXXFLAGS="${CXXFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		LDLIBS="-lgit2"
}

src_test() {
	# Reproduces the protocol smoke test that upstream's ./build script
	# runs after linking: gitstatusd must correctly identify a directory
	# that is a git repo, and one that is not.
	#
	# The repo's branch name must not depend on the build host's git
	# config (init.defaultBranch may be "master", "main", or anything
	# else an admin has set globally), so pin it explicitly via a scratch
	# HOME/.gitconfig, the same technique upstream's own ./build script
	# uses, rather than asserting against a guessed branch name.
	local daemon="${S}/usrbin/gitstatusd"
	local repo="${T}/gitstatus-test-repo"
	local branch="gitstatus-smoke-test"

	mkdir -p "${repo}" || die
	printf '[init]\n\tdefaultBranch = %s\n' "${branch}" > "${T}"/.gitconfig || die
	GIT_CONFIG_NOSYSTEM=1 HOME="${T}" git -C "${repo}" init -q || die
	GIT_CONFIG_NOSYSTEM=1 HOME="${T}" git -C "${repo}" \
		-c user.name="Test" -c user.email="test@example.com" \
		commit -q --allow-empty --allow-empty-message -m '' || die

	local resp
	resp="$(printf 'hello\037%s\036' "${repo}" | "${daemon}")" || die
	[[ "${resp}" == hello*1*"${repo}"*"${branch}"* ]] \
		|| die "gitstatusd gave an unexpected response for a git repo: ${resp}"

	resp="$(printf 'hello\037\036' | "${daemon}")" || die
	[[ "${resp}" == hello*0* ]] \
		|| die "gitstatusd gave an unexpected response for a non-repo: ${resp}"
}

src_install() {
	dobin usrbin/gitstatusd
	dodoc README.md

	# Ship the shell-integration files as a self-contained, reusable unit
	# so both this package's own users and app-shells/powerlevel10k (via
	# _POWERLEVEL9K_GITSTATUS_DIR) can point at it. Deliberately omits
	# src/, Makefile, build*, install*.info's C++ build machinery.
	insinto /usr/share/gitstatus
	doins gitstatus.plugin.zsh gitstatus.plugin.sh \
		gitstatus.prompt.zsh gitstatus.prompt.sh \
		install install.info build.info

	# The bundled `install` script auto-detects a local daemon at
	# usrbin/gitstatusd relative to its own directory before ever
	# considering a download, so this symlink makes the package work
	# out of the box with no GITSTATUS_DAEMON configuration required.
	dosym -r /usr/bin/gitstatusd /usr/share/gitstatus/usrbin/gitstatusd
}

pkg_postinst() {
	elog "For a minimal git-status prompt segment independent of any"
	elog "particular theme, source one of the following from your shell rc:"
	elog "  zsh:  source /usr/share/gitstatus/gitstatus.prompt.zsh"
	elog "  bash: source /usr/share/gitstatus/gitstatus.prompt.sh"
	elog ""
	elog "app-shells/powerlevel10k does not depend on this package: it builds"
	elog "its own bundled gitstatus commit instead, since upstream has stated"
	elog "gitstatusd and gitstatus.plugin.zsh must come from the same commit,"
	elog "which is not guaranteed to be any tagged gitstatus release."
}
