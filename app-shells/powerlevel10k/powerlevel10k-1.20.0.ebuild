# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit flag-o-matic multiprocessing readme.gentoo-r1 toolchain-funcs

DESCRIPTION="A fast and flexible Zsh theme"
HOMEPAGE="https://github.com/romkatv/powerlevel10k"

# This release bundles a specific, untagged commit of romkatv/gitstatus in
# gitstatus/ (not any of gitstatus's own tagged releases): diffing it
# against the standalone v1.5.4 and v1.5.5 tags shows it matches neither
# exactly (different pinned libgit2 fork commit than v1.5.4; several
# source-comment/string typo fixes not present in v1.5.5). Upstream has
# stated there is no stable API between gitstatusd and the
# gitstatus.plugin.zsh version it ships with ("build gitstatusd from the
# same commit... it'll work" -- romkatv, powerlevel10k#392), so gitstatusd
# is built here from powerlevel10k's own bundled copy of gitstatus rather
# than from app-shells/gitstatus, which tracks gitstatus's real releases
# and is not guaranteed to match what any given powerlevel10k release
# bundles. Any version bump of this ebuild must re-derive this pin from
# the new release's own gitstatus/build.info.
LIBGIT2_COMMIT="tag-2ecf33948a4df9ef45a66c68b8ef24a5e60eaac6"

SRC_URI="
	https://github.com/romkatv/powerlevel10k/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/romkatv/libgit2/archive/${LIBGIT2_COMMIT}.tar.gz -> libgit2-${LIBGIT2_COMMIT}.tar.gz
"
S="${WORKDIR}/${P}"
LIBGIT2_S="${WORKDIR}/libgit2-${LIBGIT2_COMMIT}"

# powerlevel10k itself: MIT.
# Bundled gitstatus (built from source below): GPL-3+.
# Vendored libgit2 fork, statically linked in: GPL-2-with-linking-exception.
# libgit2 in turn statically links in several of its own vendored
# dependencies, confirmed from actual configure output (REGEX_BACKEND=builtin
# means "libgit2's bundled PCRE", not a PCRE-free implementation): bundled
# zlib (ZLIB), bundled http-parser (MIT), bundled PCRE (BSD, per
# dev-libs/libpcre's own LICENSE in ::gentoo).
LICENSE="MIT GPL-3+ GPL-2-with-linking-exception ZLIB BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="app-shells/zsh"
BDEPEND="
	dev-build/cmake
	test? (
		dev-vcs/git
		sys-apps/util-linux
	)
"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="
In order to use ${CATEGORY}/${PN}, add the following near the top of your
~/.zshrc, before any prompt/theme initialization (e.g. before oh-my-zsh's
ZSH_THEME is applied):

source /usr/share/zsh/site-functions/powerlevel10k/powerlevel10k.zsh-theme

Run 'p10k configure' afterwards to generate ~/.p10k.zsh interactively, or
copy one of the presets from
/usr/share/zsh/site-functions/powerlevel10k/config/ instead.
"

src_configure() {
	# Reproduces the libgit2 half of upstream gitstatus's own ./build
	# script (see gitstatus/build.info / gitstatus/build), minus the
	# parts irrelevant to an ebuild: tool auto-installation, Docker
	# cross-building, and downloading the tarball at build time (we get
	# it via SRC_URI). Only the CMake feature flags are load-bearing;
	# gitstatusd never performs network git operations, so SSH/HTTPS
	# transports, NTLM and GSSAPI auth are deliberately disabled upstream.
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

	# gitstatusd's own build is a plain Makefile (see gitstatus/Makefile).
	# It only ever references $(CXXFLAGS), never $(CPPFLAGS), so the -I
	# for the vendored libgit2 fork's headers must be folded into
	# CXXFLAGS itself -- otherwise the compiler silently falls back to
	# whatever libgit2 happens to be installed system-wide, which does
	# not declare the same API this fork does and fails to build (this
	# is the same failure NixOS packagers hit: romkatv/gitstatus#7).
	#
	# Passing CXXFLAGS on the make command line (as emake does) also
	# fully overrides -- not appends to -- the Makefile's own
	# `CXXFLAGS += ...` line, including -DGITSTATUS_VERSION=$(VERSION).
	# We define it ourselves as "v1.5.4", matching the literal value in
	# the bundled gitstatus/build.info: this is p10k's own internal
	# compatibility token between gitstatus.plugin.zsh and gitstatusd
	# (checked via the daemon's -G flag), not a claim that this is
	# genuinely upstream gitstatus release v1.5.4 -- it provably isn't
	# (see the LIBGIT2_COMMIT comment above). It must track whatever
	# gitstatus/build.info says on any version bump of this ebuild.
	#
	# We also link dynamically against the system libc (unlike upstream's
	# default fully-static release binaries, which exist to be portable
	# across distros); only libgit2 remains statically linked, which is
	# how upstream's build produces it regardless of the -static toggle.
	append-cxxflags -std=c++14 -funsigned-char -D_GNU_SOURCE \
		-DGITSTATUS_ZERO_NSEC -DGITSTATUS_VERSION="v1.5.4" \
		-I"${LIBGIT2_S}/include"
	append-ldflags -L"${LIBGIT2_S}/build"

	emake -C "${S}/gitstatus" \
		CXX="$(tc-getCXX)" \
		CXXFLAGS="${CXXFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		LDLIBS="-lgit2"
}

src_test() {
	local daemon="${S}/gitstatus/usrbin/gitstatusd"
	local repo="${T}/p10k-test-repo"
	local branch="p10k-smoke-test"

	# First, the same low-level protocol smoke test as app-shells/gitstatus
	# (gitstatusd must correctly identify a repo and a non-repo). The
	# branch name must not depend on the build host's git config, so pin
	# it explicitly via a scratch HOME/.gitconfig, the same technique
	# upstream's own ./build script uses.
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

	# Genuine powerlevel10k+gitstatus end-to-end offline smoke test: drive
	# the real, unmodified integration entry points p10k's own
	# internal/p10k.zsh uses (`source gitstatus.plugin.zsh _p9k_`, then
	# call the resulting gitstatus_{start,query,stop}_p9k_ functions) --
	# not a reimplementation of that logic. This exercises exactly the
	# thing this ebuild's design is about: that the gitstatusd we just
	# built here is used with zero network access and correctly reports
	# real repo state through p10k's actual (prefixed) function names.
	#
	# gitstatus.plugin.zsh unconditionally requires `[[ -o interactive ]]`
	# and internally does `setopt monitor` (job control), neither of
	# which a plain non-interactive `zsh -c` provides; `script` allocates
	# a real pty so both succeed, and `zsh -i` forces the interactive
	# option without needing a real terminal to attach to.
	#
	# Scoped deliberately to the gitstatus integration layer rather than
	# full ANSI prompt rendering: getting a byte-exact rendered PS1 out of
	# p10k's caching/dump/wizard machinery is orthogonal to what this
	# ebuild's own correctness depends on (the gitstatus commit match and
	# offline daemon startup), and would make the test fragile against
	# upstream prompt-engine changes unrelated to this packaging.
	# Every failure branch below must `exit 1`, not just `print` a failure
	# marker: the exit status is what makes `script`'s own exit status (and
	# thus the `|| die` after it) actually fatal, independent of the
	# substring checks that follow.
	local e2e_script="${T}/p10k-e2e.zsh"
	cat > "${e2e_script}" <<-EOF
		cd "${repo}" || exit 1
		GITSTATUS_AUTO_INSTALL=0
		builtin source "${S}/gitstatus/gitstatus.plugin.zsh" _p9k_ || { print SOURCE_FAILED; exit 1 }
		if gitstatus_start_p9k_ -t 15 P10KTEST; then
			print DAEMON_STARTED
			if gitstatus_query_p9k_ -t 15 P10KTEST; then
				print "IS_REPO=\${VCS_STATUS_RESULT}"
				print "BRANCH=\${VCS_STATUS_LOCAL_BRANCH}"
			else
				print QUERY_FAILED
				gitstatus_stop_p9k_ P10KTEST
				exit 1
			fi
			gitstatus_stop_p9k_ P10KTEST
		else
			print DAEMON_START_FAILED
			exit 1
		fi
	EOF

	local out rc
	out="$(script -qec "zsh -f -i ${e2e_script}" /dev/null 2>&1)"
	rc=$?
	einfo "powerlevel10k+gitstatus end-to-end test output:"
	einfo "${out}"

	[[ ${rc} -eq 0 ]] \
		|| die "powerlevel10k+gitstatus end-to-end test script exited nonzero (${rc})"
	[[ "${out}" == *DAEMON_STARTED* ]] \
		|| die "powerlevel10k's gitstatus integration failed to start the daemon offline"
	[[ "${out}" == *"IS_REPO=ok-sync"* ]] \
		|| die "powerlevel10k's gitstatus integration did not report a clean repo"
	[[ "${out}" == *"BRANCH=${branch}"* ]] \
		|| die "powerlevel10k's gitstatus integration reported the wrong branch"
}

src_install() {
	insinto /usr/share/zsh/site-functions/powerlevel10k
	doins -r \
		powerlevel10k.zsh-theme powerlevel9k.zsh-theme \
		prompt_powerlevel10k_setup prompt_powerlevel9k_setup \
		internal config

	# Only the runtime shell-integration files plus the daemon we just
	# built from them -- not src/, Makefile, build*, or gitstatus's own
	# docs, which belong to app-shells/gitstatus's packaging, not this
	# internal build. Installed at gitstatus/ alongside the theme file
	# itself, which is exactly where powerlevel10k's own code looks by
	# default (${__p9k_root_dir}/gitstatus) -- no extra configuration
	# needed from users.
	insinto /usr/share/zsh/site-functions/powerlevel10k/gitstatus
	doins gitstatus/gitstatus.plugin.zsh gitstatus/gitstatus.plugin.sh \
		gitstatus/install gitstatus/install.info gitstatus/build.info
	exeinto /usr/share/zsh/site-functions/powerlevel10k/gitstatus/usrbin
	doexe gitstatus/usrbin/gitstatusd

	dodoc README.md font.md

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
