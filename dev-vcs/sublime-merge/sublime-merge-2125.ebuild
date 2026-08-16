# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

# Upstream does not use a major.minor scheme for Sublime Merge; PV is the
# raw build number as published at https://www.sublimemerge.com/download,
# matching the "Build 2125" string embedded in the binary itself.

DESCRIPTION="Git client from the makers of Sublime Text"
HOMEPAGE="https://www.sublimemerge.com"
SRC_URI="
	amd64? ( https://download.sublimetext.com/sublime_merge_build_${PV}_x64.tar.xz )
	arm64? ( https://download.sublimetext.com/sublime_merge_build_${PV}_arm64.tar.xz )
"
S="${WORKDIR}/${PN}"

# ::gentoo's "Sublime" license file is stale SUBLIME TEXT-only text that
# does not name Sublime Merge and predates the "Only the Linux version...
# may be distributed to third parties" redistribution exception. The
# current EULA, fetched directly from https://www.sublimehq.com/eula,
# explicitly covers "SUBLIME TEXT and SUBLIME MERGE" and includes that
# exception; it is registered locally as licenses/SublimeHQ-EULA.
LICENSE="SublimeHQ-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# sublime_merge links libX11 and libglib-2.0/libgobject-2.0 directly, and
# dlopen()s libgtk-3.so at runtime for native GTK file/dir choosers (found
# via `strings` on the prebuilt binary; not present in `readelf -d` NEEDED,
# same pattern app-editors/sublime-text uses for its own libgtk-3 dep).
# libGL.so.1 is a direct NEEDED entry, hence virtual/opengl rather than
# pinning to media-libs/mesa so proprietary GL implementations still work.
RDEPEND="
	dev-libs/glib:2
	sys-libs/glibc
	virtual/opengl
	x11-libs/gtk+:3
	x11-libs/libX11
"

QA_PREBUILT="*"

PATCHES=(
	"${FILESDIR}"/${PN}-2125-no-onlyshowin-unity.patch
)

src_unpack() {
	default

	# Upstream's tar.xz top-level directory name differs per arch
	# (sublime_merge-x64-tar / sublime_merge-arm64-tar); only one of the
	# two SRC_URI entries is ever fetched for a given KEYWORDS-matched
	# arch, so this glob is unambiguous. Rename it to the fixed ${S} so
	# the rest of the ebuild does not need to branch on arch.
	mv "${WORKDIR}"/sublime_merge-*-tar "${S}" || die
}

src_install() {
	insinto /opt/${PN}
	doins -r Packages Icon # /Icon is used at runtime by the application
	doins attribution.txt changelog.txt sublime_merge.desktop

	exeinto /opt/${PN}
	doexe crash_handler git-credential-sublime ssh-askpass-sublime sublime_merge

	dosym ../../opt/${PN}/sublime_merge usr/bin/${PN}
	# Upstream's own documented command-line tool name; see
	# https://www.sublimemerge.com/docs/command_line
	dosym ../../opt/${PN}/sublime_merge usr/bin/smerge

	domenu sublime_merge.desktop

	local size
	for size in 16 32 48 128 256; do
		doicon --size ${size} Icon/${size}x${size}/sublime-merge.png
	done
}
