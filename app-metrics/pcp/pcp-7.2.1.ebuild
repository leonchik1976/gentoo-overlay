# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python3_15 is supported by upstream and dependencies, but is untested here.
PYTHON_COMPAT=( python3_{12..15} )

DISTUTILS_EXT=1
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 optfeature qt-utils shell-completion tmpfiles xdg

DESCRIPTION="System-level performance monitoring and management framework"
HOMEPAGE="https://pcp.io/ https://github.com/performancecopilot/pcp"
SRC_URI="https://github.com/performancecopilot/pcp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="infiniband json nutcracker perfevent qt6 selinux snmp"
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
	${DISTUTILS_DEPS}
	app-alternatives/awk
	dev-lang/perl
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	qt6? ( dev-qt/qttools:6[linguist] )
"
IDEPEND="virtual/tmpfiles"

PATCHES=(
	"${FILESDIR}/${P}-honor-without-static-probes.patch"
	"${FILESDIR}/${P}-python-and-completion-metadata.patch"
)

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
		--with-python_prefix="${EPREFIX}/usr"
		--with-secure-sockets=yes
		--with-sysconfigdir="${EPREFIX}/etc/pcp/sysconfig"
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

	local python_source_dir=${S}/src/python
	local -x CFLAGS="${CFLAGS} -I${S}/src/include -I${S}/src/include/pcp"
	local -x LDFLAGS="${LDFLAGS} -L${S}/src/libpcp/src -L${S}/src/libpcp_pmda/src -L${S}/src/libpcp_gui/src -L${S}/src/libpcp_archive/src -L${S}/src/libpcp_import/src -L${S}/src/libpcp_mmv/src"
	local BUILD_DIR=${WORKDIR}/${P}-python-wheel
	local python_sitedir=$(python_get_sitedir)
	local python_image_dir=${ED}${python_sitedir#${EPREFIX}}
	rm -rf \
		"${python_image_dir}/pcp" \
		"${python_image_dir}"/cmmv.* \
		"${python_image_dir}"/cpmapi.* \
		"${python_image_dir}"/cpmda.* \
		"${python_image_dir}"/cpmgui.* \
		"${python_image_dir}"/cpmi.* \
		"${python_image_dir}"/pcp-*.egg-info || die
	pushd "${python_source_dir}" > /dev/null || die
	distutils_pep517_install "${D}"
	popd > /dev/null || die
	python_optimize

	local bashcompdir=$(get_bashcompdir)
	bashcompdir=${ED}${bashcompdir#${EPREFIX}}
	rm -rf "${bashcompdir}" || die
	newbashcomp src/bashrc/pcp_completion.sh pmstat
	bashcomp_alias pmstat \
		pcp2arrow pcp2elasticsearch pcp2graphite pcp2influxdb pcp2json \
		pcp2openmetrics pcp2opentelemetry pcp2spark pcp2xlsx pcp2xml \
		pcp2zabbix pmclient pmclient_fg pmdumplog pmdumptext pmevent \
		pmfind pmie pmie2col pmiectl pminfo pmjson pmlc pmlogcheck \
		pmlogctl pmlogdump pmlogextract pmlogger pmloglabel pmlogpaste \
		pmlogreduce pmlogsize pmlogsummary pmprobe pmrep pmseries pmstore \
		pmval

	find "${ED}" -type f \( -name '*.a' -o -name '*.la' \) -delete || die
	find "${ED}/usr/share/man" -type f -name '*.bz2' -exec bunzip2 {} + || die

	dotmpfiles "${FILESDIR}/pcp.conf"
	keepdir \
		/var/lib/pcp/config/pmda \
		/var/lib/pcp/config/pmie \
		/var/lib/pcp/pmcd \
		/var/lib/pcp/pmdas/opentelemetry/config.d

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
	xdg_pkg_postinst
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

pkg_postrm() {
	xdg_pkg_postrm
}
