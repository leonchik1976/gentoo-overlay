# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion systemd sysroot

DESCRIPTION="Cloud Native Runtime Security"
HOMEPAGE="https://falco.org/ https://github.com/falcosecurity/falco"

LIBS_COMMIT="80e695f6b123c26574cbc0f9230b33c911c71c49"
DRIVER_COMMIT="296aedabe763db465934722e5f7ca21c2d1d3596"

SRC_URI="
	amd64? (
		https://download.falco.org/packages/bin/x86_64/falco-${PV}-x86_64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://download.falco.org/packages/bin/aarch64/falco-${PV}-aarch64.tar.gz
			-> ${P}-arm64.tar.gz
	)
	https://raw.githubusercontent.com/falcosecurity/falco/${PV}/LICENSE
		-> ${P}-LICENSE
	https://raw.githubusercontent.com/falcosecurity/libs/${LIBS_COMMIT}/NOTICES
		-> ${P}-libs-NOTICES
	https://raw.githubusercontent.com/falcosecurity/libs/${DRIVER_COMMIT}/driver/GPL2.txt
		-> ${P}-driver-GPL2.txt
	https://raw.githubusercontent.com/falcosecurity/libs/${DRIVER_COMMIT}/driver/MIT.txt
		-> ${P}-driver-MIT.txt
"
S="${WORKDIR}/falco"

LICENSE="
	Apache-2.0 BSD BSD-1 BSD-2 curl GPL-2 ISC MIT MPL-2.0 public-domain Unlicense ZLIB
	|| ( public-domain MIT )
	|| ( LGPL-2.1 BSD-2 )
	|| ( GPL-2 MIT )
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="elibc_glibc? ( >=sys-libs/glibc-2.28 )"

QA_PREBUILT="
	usr/bin/falco
	usr/bin/falcoctl
	usr/share/falco/plugins/libcontainer.so
"

DRIVER_VERSION="10.2.0+driver"

src_unpack() {
	local archive=${P}-${ARCH}.tar.gz
	local upstream_arch

	case ${ARCH} in
		amd64) upstream_arch=x86_64 ;;
		arm64) upstream_arch=aarch64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	unpack "${archive}"
	mv "falco-${PV}-${upstream_arch}" "${S}" || die
	cp "${DISTDIR}/${P}-LICENSE" "${S}/LICENSE" || die
}

src_compile() {
	local shell

	for shell in bash fish zsh; do
		sysroot_try_run_prefixed ./usr/bin/falcoctl completion "${shell}" \
			> "${T}/falcoctl.${shell}" || die
	done
}

src_test() {
	local version_file=${T}/falco.version

	sysroot_try_run_prefixed ./usr/bin/falco --version > "${version_file}" || die
	if [[ -s ${version_file} ]]; then
		grep -Fq "Falco version: ${PV}" "${version_file}" || die "Version check failed"
	fi
}

src_install() {
	dobin usr/bin/falco usr/bin/falcoctl

	insinto /etc/falco
	doins -r etc/falco/.
	keepdir /etc/falco/rules.d

	insinto /etc/falcoctl
	doins -r etc/falcoctl/.

	insinto /usr/share/falco/plugins
	doins usr/share/falco/plugins/libcontainer.so

	insinto /usr/src
	doins -r "usr/src/falco-${DRIVER_VERSION}"

	dodoc LICENSE
	newdoc "${DISTDIR}/${P}-libs-NOTICES" falcosecurity-libs-NOTICES
	newdoc "${DISTDIR}/${P}-driver-GPL2.txt" driver-GPL2.txt
	newdoc "${DISTDIR}/${P}-driver-MIT.txt" driver-MIT.txt

	[[ -s ${T}/falcoctl.bash ]] && newbashcomp "${T}/falcoctl.bash" falcoctl
	[[ -s ${T}/falcoctl.fish ]] && dofishcomp "${T}/falcoctl.fish"
	[[ -s ${T}/falcoctl.zsh ]] && newzshcomp "${T}/falcoctl.zsh" _falcoctl

	newinitd "${FILESDIR}/falco.initd" falco
	newconfd "${FILESDIR}/falco.confd" falco
	systemd_dounit "${FILESDIR}/falco.service"
}

pkg_postinst() {
	elog "Falco uses the modern eBPF driver by default."
	elog "Review /etc/falco/falco.yaml and the rules under /etc/falco before starting it."
}
