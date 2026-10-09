# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion systemd sysroot

MY_PN=${PN%-bin}

DESCRIPTION="Modern UI and API for running automation tools"
HOMEPAGE="https://semaphoreui.com/ https://github.com/semaphoreui/semaphore"
SRC_URI="
	amd64? (
		https://github.com/semaphoreui/semaphore/releases/download/v${PV}/${MY_PN}_community_${PV}_linux_amd64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/semaphoreui/semaphore/releases/download/v${PV}/${MY_PN}_community_${PV}_linux_arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
	https://raw.githubusercontent.com/semaphoreui/semaphore/v${PV}/THIRD-PARTY-LICENSES.md
		-> ${P}-THIRD-PARTY-LICENSES.md
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	acct-user/semaphore
	dev-vcs/git
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_unpack() {
	local archive

	case ${ARCH} in
		amd64|arm64) archive=${P}-${ARCH}.tar.gz ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	unpack "${archive}"
	cp "${DISTDIR}/${P}-THIRD-PARTY-LICENSES.md" \
		"${WORKDIR}/THIRD-PARTY-LICENSES.md" || die
}

src_compile() {
	local shell

	for shell in bash fish zsh; do
		sysroot_try_run_prefixed ./${MY_PN} --no-config completion "${shell}" \
			> "${T}/${MY_PN}.${shell}" || die
	done
}

src_test() {
	local version_file=${T}/${MY_PN}.version

	sysroot_try_run_prefixed ./${MY_PN} --no-config version \
		> "${version_file}" || die
	if [[ -s ${version_file} ]]; then
		[[ $(<"${version_file}") == ${PV}-* ]] || die "Version check failed"
	fi
}

src_install() {
	dobin "${MY_PN}"
	dodoc LICENSE THIRD-PARTY-LICENSES.md

	[[ -s ${T}/${MY_PN}.bash ]] && newbashcomp "${T}/${MY_PN}.bash" "${MY_PN}"
	[[ -s ${T}/${MY_PN}.fish ]] && dofishcomp "${T}/${MY_PN}.fish"
	[[ -s ${T}/${MY_PN}.zsh ]] && newzshcomp "${T}/${MY_PN}.zsh" "_${MY_PN}"

	newinitd "${FILESDIR}/${MY_PN}.initd" "${MY_PN}"
	newconfd "${FILESDIR}/${MY_PN}.confd" "${MY_PN}"
	systemd_dounit "${FILESDIR}/${MY_PN}.service"
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/var/lib/${MY_PN}/config.json ]]; then
		elog "Semaphore UI requires initial configuration before its service can start."
		elog "Run the following command and complete the interactive setup:"
		elog "  su -s /bin/sh -c '/usr/bin/semaphore setup --config /var/lib/semaphore/config.json' semaphore"
	fi
}
