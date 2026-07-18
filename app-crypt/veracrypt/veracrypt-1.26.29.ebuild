# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
inherit desktop eapi9-ver linux-info pax-utils toolchain-funcs wxwidgets xdg

DESCRIPTION="Disk encryption with strong security based on TrueCrypt"
HOMEPAGE="https://www.veracrypt.fr/en/Home.html"
SRC_URI="https://github.com/${PN}/VeraCrypt/archive/VeraCrypt_${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/VeraCrypt-VeraCrypt_${PV}/src"

# The modules not linked against on Linux include (but are not limited to):
# libzip, chacha-xmm, chacha256, chachaRng, rdrand and t1ha2. Their licenses
# therefore do not apply to the resulting package. Bundled Argon2 is linked.
LICENSE="Apache-2.0 BSD RSA truecrypt-3.0 || ( Apache-2.0 CC0-1.0 )"
SLOT="0"
KEYWORDS="~arm64"
IUSE="doc X"
RESTRICT="bindist mirror"

RDEPEND="
	app-admin/sudo
	sys-apps/pcsc-lite
	sys-fs/fuse:3
	sys-fs/lvm2
	x11-libs/wxGTK:${WX_GTK_VER}=[X?]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

CONFIG_CHECK="~BLK_DEV_DM ~CRYPTO ~CRYPTO_XTS ~DM_CRYPT ~FUSE_FS"

PATCHES=(
	"${FILESDIR}/${P}-source-date-epoch.patch"
)

src_configure() {
	setup-wxwidgets
}

src_compile() {
	local myemakeargs=(
		NOSTRIP=1
		NOTEST=1
		VERBOSE=1
		WITHFUSE3=1
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		AR="$(tc-getAR)"
		RANLIB="$(tc-getRANLIB)"
		TC_EXTRA_CFLAGS="${CFLAGS}"
		TC_EXTRA_CXXFLAGS="${CXXFLAGS}"
		TC_EXTRA_LFLAGS="${LDFLAGS}"
		WX_CONFIG="${WX_CONFIG}"
		$(usex X "" "NOGUI=1")
	)

	emake "${myemakeargs[@]}"
}

src_test() {
	./Main/veracrypt --text --test || die "tests failed"
}

src_install() {
	local DOCS=( Readme.txt )

	dobin Main/veracrypt
	if use doc; then
		DOCS+=( "${S}"/../doc/EFI-DCS )
		docompress -x /usr/share/doc/${PF}/EFI-DCS
		HTML_DOCS=( "${S}"/../doc/html/. )
	fi
	einstalldocs

	newinitd "${FILESDIR}"/veracrypt.init veracrypt

	if use X; then
		local s
		for s in 16 22 24 32 48 64 128 256 512 1024; do
			newicon -s "${s}" Resources/Icons/VeraCrypt-${s}x${s}.png veracrypt.png
		done
		newicon -s scalable Resources/Icons/VeraCrypt.svg veracrypt.svg
		newicon -s scalable Resources/Icons/VeraCrypt-symbolic.svg veracrypt-symbolic.svg
		make_desktop_entry veracrypt "VeraCrypt" veracrypt "Utility;Security"
	fi

	pax-mark -m "${ED}"/usr/bin/veracrypt
}

pkg_postinst() {
	xdg_pkg_postinst

	ewarn "VeraCrypt has a very restrictive license. Please be explicitly aware"
	ewarn "of the limitations on redistribution of binaries or modified source."
	elog "Smart-card use may additionally require a running pcscd service and"
	elog "the appropriate reader driver."

	# Remove this after versions older than 1.26.7 are no longer upgrade paths.
	if ver_replacing -lt "1.26.7"; then
		ewarn "Starting with 1.26.7, TrueCrypt volumes are no longer supported."
		ewarn "Please explore alternatives such as dm-crypt to mount TrueCrypt volumes."
		ewarn "Moreover, support for RIPEMD160 and GOST89 is dropped."
		ewarn "Volumes using these algorithms will no longer mount."
	fi
}
