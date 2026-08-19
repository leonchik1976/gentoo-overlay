# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Official SD/SDHC/SDXC/SDUC Memory Card Formatter (Tuxera)"
HOMEPAGE="https://www.sdcard.org/downloads/sd-memory-card-formatter-for-linux/"
SRC_URI="
	amd64? (
		https://www.sdcard.org/downloads/formatter/eula_linux/SDCardFormatterv${PV}_Linux_x86_64.tgz
			-> ${P}-amd64.tgz
	)
	arm64? (
		https://www.sdcard.org/downloads/formatter/eula_linux/SDCardFormatterv${PV}_Linux_ARM64.tgz
			-> ${P}-arm64.tgz
	)
"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="fetch mirror strip"

QA_PREBUILT="usr/bin/format_sd"

pkg_nofetch() {
	ewarn "SD Memory Card Formatter for Linux is only distributed after clicking"
	ewarn "through the SD Association's End User License Agreement, so it cannot"
	ewarn "be fetched automatically."
	ewarn
	ewarn "To fetch the distfile(s):"
	ewarn " 1. Visit https://www.sdcard.org/downloads/sd-memory-card-formatter-for-linux/"
	ewarn " 2. Pick the download matching your architecture (x86_64 or ARM64),"
	ewarn "    read and accept the EULA to reveal the download link."
	if use amd64; then
		ewarn " 3. Save the downloaded SDCardFormatterv${PV}_Linux_x86_64.tgz as"
		ewarn "    ${P}-amd64.tgz in your DISTDIR directory."
	fi
	if use arm64; then
		ewarn " 3. Save the downloaded SDCardFormatterv${PV}_Linux_ARM64.tgz as"
		ewarn "    ${P}-arm64.tgz in your DISTDIR directory."
	fi
	ewarn " 4. Re-run emerge."
}

src_install() {
	local dir
	if [[ ${ARCH} == arm64 ]]; then
		dir="SDCardFormatterv${PV}_Linux_ARM64"
	else
		dir="SDCardFormatterv${PV}_Linux_x86_64"
	fi

	dobin "${dir}"/format_sd
	dodoc "${dir}"/License.txt
}
