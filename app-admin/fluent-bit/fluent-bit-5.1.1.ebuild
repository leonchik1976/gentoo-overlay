# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

DESCRIPTION="Fast and lightweight log, metrics, and traces processor and forwarder"
HOMEPAGE="https://fluentbit.io/ https://github.com/fluent/fluent-bit"
SRC_URI="https://github.com/fluent/fluent-bit/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${PV}"

# Fluent Bit itself is Apache-2.0. This ebuild links against system
# copies of msgpack, c-ares, nghttp2, sqlite, zstd, OpenSSL and
# (optionally) luajit/librdkafka/jemalloc instead of the bundled
# vendored copies in lib/, per FLB_PREFER_SYSTEM_LIB_* build options.
# Remaining bundled components (cmetrics, ctraces, chunkio, cfl,
# monkey, etc.) are Fluent Bit's own sub-projects with no separate
# system packages available and are built from the bundled sources.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="+jemalloc kafka luajit +systemd"
# With -DFLB_IN_SYSTEMD=No alone, the build previously failed to
# *link* (not just skip the in_systemd input plugin as its name
# implies):
#   ne_systemd.c:(.text+0xae0): undefined reference to `sd_bus_get_property_trivial'
#   library/libflb-plugin-in_node_exporter_metrics.a(ne_systemd.c.o)
# in_node_exporter_metrics (a separate input plugin, not gated by
# FLB_IN_SYSTEMD) also calls into libsystemd's sd-bus API in its own
# ne_systemd.c, and upstream's CMakeLists.txt only adds -lsystemd to
# the final executable's link libraries when FLB_IN_SYSTEMD is
# enabled -- so disabling only FLB_IN_SYSTEMD broke the link instead
# of dropping the dependency. FLB_IN_NODE_EXPORTER_METRICS
# (cmake/plugins_options.cmake, default ON) is its own dedicated,
# documented toggle that keeps that plugin's sources -- including
# ne_systemd.c -- out of the build entirely when disabled, which is
# what actually removes the sd-bus requirement. Verified with a full
# clean configure+compile at all three of USE=systemd,
# USE=-systemd (with FLB_IN_NODE_EXPORTER_METRICS also off), and the
# original broken combination (FLB_IN_SYSTEMD off alone), not
# inferred from reading CMakeLists.txt.

ACCT_DEPEND="
	acct-group/fluent-bit
	acct-user/fluent-bit
"
RDEPEND="
	${ACCT_DEPEND}
	app-arch/zstd:=
	dev-libs/libyaml:=
	dev-libs/msgpack:=
	dev-libs/openssl:=
	net-dns/c-ares:=
	net-libs/nghttp2:=
	dev-db/sqlite:=
	systemd? ( sys-apps/systemd:= )
	jemalloc? ( dev-libs/jemalloc:= )
	kafka? ( dev-libs/librdkafka:= )
	luajit? ( dev-lang/luajit:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/bison
	sys-devel/flex
"

RESTRICT="test"

# GCC -Wfree-nonheap-object false positive in bundled Monkey's
# mk_stream_release(): see the patch file itself for the full
# root-cause analysis, upstream issue reference, and validation.
PATCHES=(
	"${FILESDIR}"/${P}-mk_stream_release-nonheap-object.patch
)

src_configure() {
	local mycmakeargs=(
		-DFLB_RELEASE=Yes
		-DFLB_DEBUG=No
		-DFLB_PREFER_SYSTEM_LIBS=Yes
		-DFLB_JEMALLOC=$(usex jemalloc)
		-DFLB_PREFER_SYSTEM_LIB_JEMALLOC=$(usex jemalloc)
		-DFLB_KAFKA=$(usex kafka)
		-DFLB_PREFER_SYSTEM_LIB_KAFKA=$(usex kafka)
		-DFLB_LUAJIT=$(usex luajit)
		-DFLB_PREFER_SYSTEM_LIB_LUAJIT=$(usex luajit)
		-DFLB_IN_SYSTEMD=$(usex systemd)
		# in_node_exporter_metrics's own ne_systemd.c compiles in
		# sd-bus calls whenever libsystemd/sd-bus headers are found
		# on the build host (gated by FLB_HAVE_SYSTEMD_SDBUS, which
		# upstream ties to journald detection, NOT to FLB_IN_SYSTEMD)
		# -- so with USE=-systemd this plugin must be disabled too,
		# or the link fails the same way it always did. This drops
		# its non-systemd host metrics (cpu/disk/meminfo via /proc)
		# along with the systemd-unit ones; there is no finer-grained
		# upstream toggle to keep only the former.
		-DFLB_IN_NODE_EXPORTER_METRICS=$(usex systemd)
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DFLB_WASM=No
		-DFLB_ARROW=No
		-DFLB_AVRO_ENCODER=No
		-DFLB_EXAMPLES=No
		-DFLB_TESTS_RUNTIME=No
		-DFLB_TESTS_INTERNAL=No
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	systemd_newunit "${FILESDIR}"/fluent-bit.service fluent-bit.service

	keepdir /var/lib/fluent-bit
	fowners fluent-bit:fluent-bit /var/lib/fluent-bit
}
