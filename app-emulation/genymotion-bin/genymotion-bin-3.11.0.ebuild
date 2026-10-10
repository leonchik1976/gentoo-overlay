# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop shell-completion xdg

MY_PN="${PN/-bin}"
MY_P="${MY_PN}-${PV}"
BIN_ARCHIVE="${MY_P}-linux_x64.run"

DESCRIPTION="Complete set of tools that provide a virtual environment for Android"
HOMEPAGE="https://www.genymotion.com"
SRC_URI="https://dl.genymotion.com/releases/${MY_P}/${BIN_ARCHIVE}"
S="${WORKDIR}/${MY_PN}"

LICENSE="genymotion"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

# Keep upstream's private libraries, including the exact hiredis ABI.
# Use Gentoo's QEMU instead of the bundled hypervisor.
RDEPEND="
	app-emulation/qemu[qemu_softmmu_targets_x86_64]
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/libpulse
	virtual/opengl
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/pixman
"

QA_PREBUILT="opt/${MY_PN}/*"

src_unpack() {
	mkdir "${S}" || die
	# Extract the payload without executing upstream's installer, which writes
	# desktop files and settings outside the package image.
	local skip
	skip=$(awk '/^__TARFILE_FOLLOWS__/ { print NR + 1; exit }' \
		"${DISTDIR}/${BIN_ARCHIVE}") || die
	[[ -n ${skip} ]] || die "Installer payload marker not found"
	tail -n +"${skip}" "${DISTDIR}/${BIN_ARCHIVE}" |
		tar -xjf - --no-same-owner -C "${S}" || die "Payload extraction failed"
}

src_prepare() {
	default
	sed -i '/complete -F _gmtool gmtool.exe/d' completion/bash/gmtool.bash || die
}

src_install() {
	local entry
	dodir /opt/${MY_PN}
	for entry in *; do
		case ${entry} in
			completion|qemu) continue ;;
		esac
		cp -a "${entry}" "${ED}/opt/${MY_PN}/" || die
	done

	dosym -r /usr/bin/qemu-system-x86_64 /opt/${MY_PN}/qemu/x86_64/bin/qemu-system-x86_64
	dosym -r /usr/bin/qemu-img /opt/${MY_PN}/qemu/x86_64/bin/qemu-img
	for entry in genymotion genyshell gmtool; do
		dosym -r /opt/${MY_PN}/${entry} /opt/bin/${entry}
	done
	newbashcomp completion/bash/gmtool.bash gmtool
	dozshcomp completion/zsh/_gmtool

	make_desktop_entry --eapi9 --desktopid genymotion-launchpad --args "%U" \
		--name Genymotion --icon "${EPREFIX}/opt/${MY_PN}/icons/genymotion-logo.png" \
		--categories "Development;Emulator;" \
		--entry "MimeType=x-scheme-handler/genymotion;" --entry "StartupWMClass=genymotion" \
		"${EPREFIX}/opt/${MY_PN}/genymotion"
	make_desktop_entry --eapi9 --desktopid genymotion-player --args "%U" \
		--name "Genymotion Player" --icon "${EPREFIX}/opt/${MY_PN}/icons/player-logo.png" \
		--categories "Development;Emulator;" \
		--entry "NoDisplay=true" --entry "StartupWMClass=player" \
		"${EPREFIX}/opt/${MY_PN}/player"
}
