# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python3_15 is supported by upstream and dependencies, but is untested here.
PYTHON_COMPAT=( python3_{12..15} )

inherit optfeature python-single-r1 qt-utils tmpfiles

DESCRIPTION="System-level performance monitoring and management framework"
HOMEPAGE="https://pcp.io/ https://github.com/performancecopilot/pcp"
SRC_URI="https://github.com/performancecopilot/pcp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="discovery infiniband json nutcracker perfevent qt6 selinux snmp"
# The SELinux integration is intentionally untested.
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

RDEPEND="
	${PYTHON_DEPS}
	!!dev-db/pgpool2
	acct-group/pcp
	acct-user/pcp
	dev-lang/perl:=
	dev-libs/cyrus-sasl
	dev-libs/libuv
	dev-libs/openssl:=
	sys-apps/systemd
	sys-libs/ncurses:=
	virtual/zlib
	discovery? ( net-dns/avahi[dbus] )
	infiniband? ( sys-cluster/rdma-core )
	json? (
		$(python_gen_cond_dep '
			dev-python/jsonpointer[${PYTHON_USEDEP}]
			dev-python/six[${PYTHON_USEDEP}]
		')
	)
	nutcracker? (
		dev-perl/YAML-LibYAML
		virtual/perl-JSON-PP
	)
	perfevent? ( dev-libs/libpfm )
	qt6? (
		dev-qt/qtbase:6[gui,widgets]
		dev-qt/qtsvg:6
	)
	selinux? ( sys-libs/libselinux )
	snmp? ( dev-perl/Net-SNMP )
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/awk
	dev-lang/perl
	$(python_gen_cond_dep 'dev-python/setuptools[${PYTHON_USEDEP}]')
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	qt6? ( dev-qt/qttools:6[linguist] )
"
IDEPEND="virtual/tmpfiles"

PATCHES=( "${FILESDIR}/${P}-honor-without-static-probes.patch" )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_configure() {
	if use qt6; then
		export QMAKE="$(qt_get_broot_binary 6 qmake)"
	fi

	local myeconfargs=(
		--enable-pie
		--enable-ssp
		--enable-visibility
		--localstatedir="${EPREFIX}/var"
		--with-group=pcp
		--with-perl=yes
		--with-python3="${EPYTHON}"
		--with-python-prefix="${EPREFIX}/usr"
		--with-secure-sockets=yes
		--with-sysconfigdir="${EPREFIX}/etc/conf.d"
		--with-systemd=yes
		--with-threads=yes
		--with-transparent-decompression=yes
		--with-user=pcp
		--without-dstat-symlink
		--without-gperftools
		--without-pmdabpf
		--without-pmdabpftrace
		--without-pmdagfs2
		--without-pmdamongodb
		--without-pmdamysql
		--without-pmdastatsd
		--without-qt3d
		--without-sanitizer
		--without-static-probes
		--without-x
		$(use_with discovery)
		$(use_with infiniband)
		$(use_with json pmdajson)
		$(use_with nutcracker pmdanutcracker)
		$(use_with perfevent)
		$(use_with qt6 qt)
		$(use_with selinux)
		$(use_with snmp pmdasnmp)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake
}

src_install() {
	emake DIST_ROOT="${ED}" install
	python_optimize

	find "${ED}" -type f \( -name '*.a' -o -name '*.la' \) -delete || die
	find "${ED}/usr/share/man" -type f -name '*.bz2' -exec bunzip2 {} + || die

	dotmpfiles "${FILESDIR}/pcp.conf"

	if [[ -d ${ED}/usr/share/doc/pcp-doc/html ]]; then
		dodir "/usr/share/doc/${PF}"
		mv "${ED}/usr/share/doc/pcp-doc/html" "${ED}/usr/share/doc/${PF}/" || die
	fi
	rm -rf \
		"${ED}/run" \
		"${ED}/var/lib/pcp/testsuite" \
		"${ED}/var/lib/pcp/tmp" \
		"${ED}/var/log" \
		"${ED}/usr/share/doc/pcp-doc" || die
}

pkg_postinst() {
	tmpfiles_process pcp.conf
	optfeature "ActiveMQ metric collection" dev-perl/libwww-perl
	optfeature "BIND metric collection" dev-perl/File-Slurp dev-perl/libwww-perl dev-perl/XML-LibXML
	optfeature "InfluxDB metric export" dev-python/requests
	optfeature "libvirt metric collection" dev-python/libvirt-python dev-python/lxml
	optfeature "MySQL metric collection" dev-perl/DBD-mysql
	optfeature "nginx metric collection" dev-perl/libwww-perl
	optfeature "Podman metric collection" app-containers/podman
	optfeature "PostgreSQL metric collection" dev-python/psycopg:2
	optfeature "XLSX metric export" dev-python/openpyxl
	einfo "Enable pmcd and pmlogger to collect local performance metrics."
}
