# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# cmake.eclass currently only supports EAPI 8 (see @SUPPORTED_EAPIS in
# /var/db/repos/gentoo/eclass/cmake.eclass); fall back from the repository's
# preferred EAPI 9 until it does.
inherit cmake linux-info

DESCRIPTION="Userspace daemon for the LIO TCM-User (TCMU) SCSI target backstore"
HOMEPAGE="https://github.com/open-iscsi/tcmu-runner"
SRC_URI="https://github.com/open-iscsi/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="glusterfs +rbd +systemd tcmalloc"

# target_core_user is only needed at runtime to attach TCMU-backed LUNs;
# tcmu-runner itself still builds and starts without it, so this is a
# non-fatal (soft) warning, not a build-time or merge-time failure.
CONFIG_CHECK="~TCM_USER2"
WARNING_TCM_USER2="CONFIG_TCM_USER2 (Target Core User support) is not set. ${PN} needs the target_core_user kernel module (built-in or loaded) to attach any TCMU-backed LUN."

RDEPEND="
	dev-libs/glib:2
	dev-libs/libnl:3=
	sys-apps/dbus
	sys-apps/kmod
	virtual/zlib:=
	glusterfs? ( sys-cluster/glusterfs )
	rbd? ( sys-cluster/ceph:= )
	tcmalloc? ( >=dev-util/google-perftools-2.6.1:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gdbus-codegen
	virtual/pkgconfig
"

# Upstream's cmake_minimum_required(VERSION 2.8) trips CMake 4's removal of
# support for policies below 3.5 (bug #951350) and its warning that support
# below 3.10 will go away too. See the patch header for details; sent
# upstream-clean (no other change) so it can be submitted as-is.
PATCHES=( "${FILESDIR}/${P}-cmake-minimum-3.10.patch" )

src_prepare() {
	cmake_src_prepare

	# tcmu.conf and logrotate.conf are installed via two install(SCRIPT ...)
	# rules (tcmu.conf_install.cmake.in / logrotate.conf_install.cmake.in)
	# whose EXISTS check reads the *live* /etc (not $D) to decide whether to
	# stash a previous config as *.old -- RPM %ghost-style backup logic with
	# no Gentoo equivalent, since CONFIG_PROTECT already handles this and the
	# EXISTS check would depend on build-host state rather than the package.
	# Drop both install(SCRIPT) rules; the configs are installed directly in
	# src_install() instead.
	sed -i \
		-e '/install(SCRIPT tcmu\.conf_install\.cmake)/d' \
		-e '/install(SCRIPT logrotate\.conf_install\.cmake)/d' \
		CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DSUPPORT_SYSTEMD=$(usex systemd)
		-Dwith-rbd=$(usex rbd)
		-Dwith-glfs=$(usex glusterfs)
		-Dwith-qcow=true
		-Dwith-zbc=true
		-Dwith-fbo=true
		-Dwith-tcmalloc=$(usex tcmalloc)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	insinto /etc/tcmu
	doins "${S}"/tcmu.conf

	insinto /etc/logrotate.d
	newins "${S}"/logrotate.conf tcmu-runner
}
