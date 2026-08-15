# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python3_15 is supported by upstream and dependencies, but is untested here.
PYTHON_COMPAT=( python3_{11..15} )

inherit optfeature pam python-single-r1 tmpfiles xdg

DESCRIPTION="Web-based graphical interface for servers"
HOMEPAGE="https://cockpit-project.org/"
SRC_URI="https://github.com/cockpit-project/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+ GPL-3+ MIT CC-BY-SA-3.0 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cockpit-client debug doc kdump networkmanager selinux sosreport test udisks"

# The SELinux integration and its dependency stack are intentionally untested.

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.68
	>=dev-libs/json-glib-1.4
	>=net-libs/gnutls-3.6.0
	>=sys-apps/systemd-235
	sys-libs/pam
	virtual/krb5
	virtual/libcrypt:=
"
DEPEND="${COMMON_DEPEND}
	selinux? ( sec-policy/selinux-base )
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libpwquality
	dev-libs/openssl
	net-libs/glib-networking[ssl]
	net-misc/openssh
	sys-apps/shadow
	sys-auth/polkit[systemd]
	cockpit-client? (
		$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
		gui-libs/gtk:4[introspection]
		gui-libs/libadwaita:1[introspection]
		net-libs/webkit-gtk:6[introspection]
	)
	kdump? ( sys-apps/kexec-tools )
	networkmanager? ( >=net-misc/networkmanager-1.6[policykit,systemd] )
	selinux? (
		app-admin/setroubleshoot
		app-admin/setroubleshoot-plugins
	)
	sosreport? ( app-admin/sosreport )
	udisks? (
		$(python_gen_cond_dep 'dev-python/dbus-python[${PYTHON_USEDEP}]')
		>=sys-fs/udisks-2.9[daemon,introspection,systemd]
	)
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pip[${PYTHON_USEDEP}]')
	sys-devel/gettext
	virtual/pkgconfig
	selinux? (
		app-arch/bzip2
		sec-policy/selinux-base
	)
	test? (
		dev-debug/gdb
		$(python_gen_cond_dep '
			dev-python/pytest-asyncio[${PYTHON_USEDEP}]
			dev-python/pytest-timeout[${PYTHON_USEDEP}]
		')
		sys-process/procps
	)
"

PATCHES=( "${FILESDIR}/${P}-install-legal-files-once.patch" )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	local po
	for po in po/*.po; do
		printf '%s\n' "${po##*/}"
	done > po/LINGUAS || die
	sed -i -e 's/\.po$//' po/LINGUAS || die
	# The release tarball ships a prebuilt web bundle.  Keep this generated
	# input older than its stamp so that make does not try to rebuild dist/.
	touch -r package-lock.json po/LINGUAS || die
}

src_configure() {
	local myeconfargs=(
		$(use_enable cockpit-client)
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable selinux selinux-policy targeted)
		--disable-multihost
		--with-admin-group=wheel
		--with-pamdir="$(getpam_mod_dir)"
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	local -x PIP_NO_CACHE_DIR=1
	local -x PIP_ROOT_USER_ACTION=ignore

	emake DESTDIR="${D}" install
	python_optimize

	newpamd "${FILESDIR}/cockpit.pam" cockpit

	insinto /etc/cockpit
	doins "${FILESDIR}/disallowed-users"
	keepdir /etc/cockpit/ws-certs.d

	# These pages are separately selectable integrations. PackageKit is not
	# installed because it has no maintained Portage backend.
	use kdump || rm -r "${ED}/usr/share/cockpit/kdump" || die
	use networkmanager || rm -r "${ED}/usr/share/cockpit/networkmanager" || die
	use selinux || rm -r "${ED}/usr/share/cockpit/selinux" || die
	use sosreport || rm -r "${ED}/usr/share/cockpit/sosreport" || die
	use udisks || rm -r "${ED}/usr/share/cockpit/storaged" || die
	rm -rf "${ED}/usr/share/cockpit/packagekit" \
		"${ED}/usr/share/cockpit/apps" \
		"${ED}/usr/share/cockpit/playground" || die
	rm -rf \
		"${ED}/usr/share/cockpit/branding/arch" \
		"${ED}/usr/share/cockpit/branding/centos" \
		"${ED}/usr/share/cockpit/branding/debian" \
		"${ED}/usr/share/cockpit/branding/fedora" \
		"${ED}/usr/share/cockpit/branding/opensuse" \
		"${ED}/usr/share/cockpit/branding/rhel" \
		"${ED}/usr/share/cockpit/branding/ubuntu" || die
	rm -f \
		"${ED}/etc/motd.d/cockpit" \
		"${ED}/etc/issue.d/cockpit.issue" || die

	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	tmpfiles_process cockpit-ws.conf
	xdg_pkg_postinst

	optfeature "historical performance metrics" app-metrics/pcp
	optfeature "firewall management" net-firewall/firewalld
	optfeature "performance profile management" sys-apps/tuned
	optfeature "sudo-based privilege escalation" app-admin/sudo
}

pkg_postrm() {
	xdg_pkg_postrm
}
