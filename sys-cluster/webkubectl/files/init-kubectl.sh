#!/bin/bash
# Adapted from upstream init-kubectl.sh: drops the bundled
# kubectl-aliases/vimrc extras that are not installed by this
# package and uses Gentoo filesystem paths.
#
# Session directory: upstream mounts tmpfs on a fixed path
# (/nonexistent) shared by name across every session. Each session
# already runs in its own mount namespace (unshare --mount in
# start-session.sh), so concurrent sessions cannot see each other's
# tmpfs contents either way -- but a fixed root-level path still (a)
# gets created as a real, permanent directory on the host's
# underlying filesystem the first time this runs (mount namespaces
# isolate mount points, not preceding mkdir calls against the
# already-mounted root), and (b) gives every session's data the same
# on-disk name, which is unnecessary ambiguity. Use a unique
# directory per session under the service's own writable data
# directory instead, and remove it again when the session ends (see
# cleanup() below) -- otherwise these accumulate forever, one per
# terminal session ever opened.
#
# Cluster credentials: upstream accepts a base64 kubeconfig or a
# server+token pair as caller-supplied arguments passed straight
# through from the browser's URL to this script -- i.e. any visitor
# can point this at an arbitrary cluster with arbitrary credentials.
# This package's unit already disables that (--permit-arguments=false
# in webkubectl.service), which makes that whole code path dead
# regardless; this script now reflects that intentionally rather than
# leaving unreachable code behind. Every session instead uses a
# single kubeconfig the administrator places on the host -- this
# service proxies terminal access to whatever cluster(s) that
# kubeconfig points at, and nothing else.
set -e

if [ "${WELCOME_BANNER}" ]; then
	echo "${WELCOME_BANNER}"
fi

sessiondir=$(mktemp -d /var/lib/webkubectl/session.XXXXXXXXXX)
cleanup() {
	cd /
	umount "${sessiondir}" 2>/dev/null || true
	rmdir "${sessiondir}" 2>/dev/null || true
}
trap cleanup EXIT

mount -t tmpfs -o size="${SESSION_STORAGE_SIZE:-10M}" tmpfs "${sessiondir}"
# /var/lib/webkubectl itself is 0711 (traversal-only, no listing) so
# that "nobody" can reach into its own session directory below --
# each session's own root still needs to be 0700 owned by nobody
# itself, since the mount above replaces whatever mode mktemp gave
# the original mountpoint with tmpfs's own default.
chown nobody:nogroup "${sessiondir}"
chmod 0700 "${sessiondir}"
cd "${sessiondir}"
echo 'PS1="> "' >> .bashrc
echo 'alias ll="ls -la"' >> .bashrc
mkdir -m 0700 -p .kube

export HOME="${sessiondir}"
export USER=nobody
export LOGNAME=nobody
export SHELL=/bin/bash

admin_kubeconfig=${WEBKUBECTL_KUBECONFIG:-/etc/webkubectl/kubeconfig}
if [ ! -r "${admin_kubeconfig}" ]; then
	echo "No kubeconfig configured. An administrator must place a" \
		"kubeconfig at ${admin_kubeconfig} (readable by this" \
		"service's user) before webkubectl can reach a cluster."
	exit 1
fi
cp "${admin_kubeconfig}" .kube/config
chmod 0600 .kube/config

if [ "${KUBECTL_INSECURE_SKIP_TLS_VERIFY}" = "true" ]; then
	clusters=$(kubectl config get-clusters | tail -n +2)
	for s in ${clusters}; do
		kubectl config set-cluster "${s}" --insecure-skip-tls-verify=true > /dev/null 2>&1 || true
		kubectl config unset clusters."${s}".certificate-authority-data > /dev/null 2>&1 || true
	done
fi

chown -R nobody:nogroup .kube
chmod 0700 .kube
chmod 0600 .kube/config

export TMPDIR="${sessiondir}"

for env_name in $(env | grep '^GOTTY' | cut -d= -f1); do
	unset "${env_name}"
done
unset WELCOME_BANNER PPROF_ENABLED KUBECTL_INSECURE_SKIP_TLS_VERIFY SESSION_STORAGE_SIZE WEBKUBECTL_KUBECONFIG

# --preserve-environment: without it, su resets HOME/USER/LOGNAME/
# SHELL to nobody's own /etc/passwd entry (HOME=/var/empty on this
# system) regardless of what was exported above, which broke
# kubectl's own default ~/.kube/config discovery -- confirmed by an
# actual real session ("No such file or directory" against
# /var/empty/.kube/config, while the file genuinely existed, correctly
# owned and readable, at ${sessiondir}/.kube/config the whole time).
# With it, su keeps every variable set above (HOME, USER, LOGNAME,
# SHELL, TMPDIR, the explicit nobody identity) and the sanitization
# immediately above (stripped GOTTY_*, WELCOME_BANNER, etc.) intact,
# while still actually switching the process's real/effective uid and
# gid to nobody -- confirmed via /proc/self/status inside an actual
# session: Uid/Gid all 65534, CapEff all zero.
#
# Not exec'd: cleanup() above must still run once this returns.
su --preserve-environment -s /bin/bash nobody
