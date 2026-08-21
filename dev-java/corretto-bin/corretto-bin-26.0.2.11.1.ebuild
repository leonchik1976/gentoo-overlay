# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-vm-2 optfeature toolchain-funcs

MY_PV=${PV/_p/+}

DESCRIPTION="Prebuilt Java JDK binaries provided by Amazon Web Services"
HOMEPAGE="https://aws.amazon.com/corretto/"
SRC_URI="
	amd64? (
		elibc_glibc? (
			https://corretto.aws/downloads/resources/${PV}/amazon-corretto-${PV}-linux-x64.tar.gz
		)
		elibc_musl? (
			https://corretto.aws/downloads/resources/${PV}/amazon-corretto-${PV}-alpine-linux-x64.tar.gz
		)
	)
	arm64? (
		elibc_glibc? (
			https://corretto.aws/downloads/resources/${PV}/amazon-corretto-${PV}-linux-aarch64.tar.gz
		)
		elibc_musl? (
			https://corretto.aws/downloads/resources/${PV}/amazon-corretto-${PV}-alpine-linux-aarch64.tar.gz
		)
	)
"
S="${WORKDIR}/${P}"

LICENSE="GPL-2-with-classpath-exception Apache-2.0"
SLOT=$(ver_cut 1)
KEYWORDS="~amd64 ~arm64"
IUSE="alsa headless-awt selinux source"

RDEPEND+="
	>=sys-apps/baselayout-java-0.1.0-r1
	kernel_linux? (
		media-libs/fontconfig:1.0
		media-libs/freetype:2
		media-libs/harfbuzz
		elibc_glibc? ( >=sys-libs/glibc-2.2.5:* )
		elibc_musl? ( sys-libs/musl )
		virtual/zlib:=
		alsa? ( media-libs/alsa-lib )
		selinux? ( sec-policy/selinux-java )
		!headless-awt? (
			x11-libs/libX11
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXrender
			x11-libs/libXtst
		)
	)
"

RESTRICT="preserve-libs splitdebug"
QA_PREBUILT="*"

pkg_pretend() {
	if [[ $(tc-is-softfloat) != no ]]; then
		die "These binaries require a hardfloat system."
	fi
}

src_unpack() {
	default

	local upstream_arch upstream_platform=linux
	case ${ARCH} in
		amd64) upstream_arch=x64 ;;
		arm64) upstream_arch=aarch64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac
	use elibc_musl && upstream_platform=alpine-linux

	mv "${WORKDIR}/amazon-corretto-${MY_PV}-${upstream_platform}-${upstream_arch}" \
		"${S}" || die
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}/${dest#/}"

	# https://bugs.gentoo.org/922741
	docompress "${dest}/man"

	if ! use alsa; then
		rm -v lib/libjsound.* || die
	fi

	if use headless-awt; then
		rm -fv lib/lib*{[jx]awt,splashscreen}* || die
	fi

	if ! use source; then
		rm -v lib/src.zip || die
	fi

	rm -v lib/security/cacerts || die
	dosym -r /etc/ssl/certs/java/cacerts "${dest}"/lib/security/cacerts

	dodir "${dest}"
	cp -pPR * "${ddest}" || die

	# Provide a stable symlink for the slot.
	dosym "${P}" "/opt/${PN}-${SLOT}"

	java-vm_install-env "${FILESDIR}"/${PN}.env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}

pkg_postinst() {
	java-vm-2_pkg_postinst
	optfeature "CUPS printing support" net-print/cups
}
