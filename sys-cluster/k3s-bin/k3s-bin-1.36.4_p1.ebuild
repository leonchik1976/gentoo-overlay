# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info systemd

MY_PN="${PN%-bin}"

# k3s tags releases as "vX.Y.Z+k3sN", which is not a valid Gentoo version.
# Map the "+k3sN" suffix to "_pN" and reverse the mapping to fetch upstream.
REMOTE_PV="${PV/_p/+k3s}"

DESCRIPTION="Lightweight Kubernetes distribution"
HOMEPAGE="https://k3s.io/ https://github.com/k3s-io/k3s"

SRC_URI="
	amd64? ( https://github.com/k3s-io/k3s/releases/download/v${REMOTE_PV}/k3s -> ${P}-amd64 )
	arm64? ( https://github.com/k3s-io/k3s/releases/download/v${REMOTE_PV}/k3s-arm64 -> ${P}-arm64 )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
# k3s's own go.mod (467 direct+indirect modules, licenses resolved via
# deps.dev; 10 unresolved entries are all k3s-io replace-directives for
# forks of Apache-2.0 kubernetes staging/cri-tools/kube-router modules,
# already covered by the top-level Apache-2.0 above):
LICENSE+="
	BSD BSD-2 CC-BY-SA-4.0 ISC MIT MPL-2.0 POSTGRESQL
"
# Plus the embedded k3s-root userspace (v0.15.2, pinned in scripts/version.sh
# and baked into the binary via go:embed): a Buildroot-produced static
# busybox/coreutils/iproute2/iptables-nft/nftables/ipset/ebtables/ethtool/
# conntrack-tools/slirp4netns/fuse-overlayfs image plus their library deps
# (util-linux, libseccomp, libcap, gmp, glib2, libxml2, libnftnl/libmnl/
# libnfnetlink/libnetfilter_*, pcre/pcre2, zlib, jansson, libffi, linenoise,
# libtirpc). This pulls in copyleft licenses the top-level Apache-2.0 does
# not cover, most notably GPL-3 (coreutils) and GPL-2 (busybox and most of
# the netfilter/iproute2 tooling):
LICENSE+="
	GPL-2 GPL-3 LGPL-2.1 LGPL-3 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+kubectl-symlink +ctr-symlink +crictl-symlink"

RDEPEND="
	kubectl-symlink? ( !sys-cluster/kubectl )
	ctr-symlink? ( !app-containers/containerd )
	crictl-symlink? ( !app-containers/cri-tools )
"

# strip: upstream ships the binary already stripped (file(1) reports
# "stripped"); re-running strip is a pointless no-op at best.
# test: no usable test suite ships with the release binary.
# mirror/bindist: the embedded k3s-root userspace includes GPL-2/GPL-3
# components (busybox, coreutils, iproute2, iptables-nft/nftables, etc; see
# LICENSE below). GPL's redistribution terms require the corresponding
# source to be made available alongside the binary; this ebuild does not
# yet do that (k3s-root's own source is on GitHub, but this ebuild neither
# fetches nor points at the exact matching source for what's embedded in
# this specific release). Keep both restrictions until that's addressed.
RESTRICT="bindist mirror strip test"

QA_PREBUILT="usr/bin/${MY_PN}"

# Derived from contrib/util/check-config.sh in the k3s source tree at this
# exact release tag (https://github.com/k3s-io/k3s/blob/v${REMOTE_PV}/contrib/util/check-config.sh).
# k3s bundles its own containerd, runc and CNI plugins, so no additional
# container-runtime kernel config beyond this list is required.
CONFIG_CHECK="
	~NAMESPACES ~NET_NS ~PID_NS ~IPC_NS ~UTS_NS
	~CGROUPS ~CGROUP_PIDS ~CGROUP_CPUACCT ~CGROUP_DEVICE ~CGROUP_FREEZER ~CGROUP_SCHED ~CPUSETS ~MEMCG
	~SECCOMP ~KEYS
	~VETH ~BRIDGE ~BRIDGE_NETFILTER
	~IP_NF_FILTER ~IP_NF_TARGET_MASQUERADE ~IP_NF_TARGET_REJECT
	~NETFILTER_XT_MATCH_ADDRTYPE ~NETFILTER_XT_MATCH_CONNTRACK ~NETFILTER_XT_MATCH_IPVS
	~NETFILTER_XT_MATCH_COMMENT ~NETFILTER_XT_MATCH_MULTIPORT ~NETFILTER_XT_MATCH_STATISTIC
	~IP_NF_NAT ~NF_NAT
	~POSIX_MQUEUE

	~USER_NS
	~BLK_CGROUP ~BLK_DEV_THROTTLING
	~CGROUP_PERF ~CGROUP_HUGETLB
	~NET_CLS_CGROUP ~CGROUP_NET_PRIO
	~CFS_BANDWIDTH ~FAIR_GROUP_SCHED ~RT_GROUP_SCHED
	~IP_NF_TARGET_REDIRECT
	~IP_SET
	~IP_VS ~IP_VS_NFCT ~IP_VS_PROTO_TCP ~IP_VS_PROTO_UDP ~IP_VS_RR
	~EXT4_FS ~EXT4_FS_POSIX_ACL ~EXT4_FS_SECURITY

	~VXLAN
	~OVERLAY_FS
"

pkg_setup() {
	linux-info_pkg_setup
}

src_unpack() {
	cp "${DISTDIR}/${P}-${ARCH}" "${WORKDIR}/${MY_PN}" || die
}

src_install() {
	dobin "${MY_PN}"

	systemd_dounit "${FILESDIR}/${MY_PN}.service"
	systemd_dounit "${FILESDIR}/${MY_PN}-agent.service"
	dobin "${FILESDIR}/${MY_PN}-killall.sh"

	use kubectl-symlink && dosym "${MY_PN}" "/usr/bin/kubectl"
	use crictl-symlink && dosym "${MY_PN}" "/usr/bin/crictl"
	use ctr-symlink && dosym "${MY_PN}" "/usr/bin/ctr"
}

pkg_postinst() {
	elog "This package installs ${MY_PN}.service (control-plane/server) and"
	elog "${MY_PN}-agent.service (worker/agent). Enable whichever matches this"
	elog "node's role; do not enable both."
	elog
	elog "Configure ${MY_PN} itself via ${EROOT}/etc/rancher/${MY_PN}/config.yaml,"
	elog "not by editing the unit files. Use a systemd drop-in only for"
	elog "unit-level overrides, e.g.:"
	elog "  systemctl edit ${MY_PN}.service"
	elog "  systemctl edit ${MY_PN}-agent.service"
	elog
	elog "${MY_PN} bundles its own containerd, runc, and CNI plugins under"
	elog "/var/lib/rancher/${MY_PN}/data; no separate container runtime needs"
	elog "to be installed."
}
