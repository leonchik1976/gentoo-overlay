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
cd "${sessiondir}"
echo 'PS1="> "' >> .bashrc
echo 'alias ll="ls -la"' >> .bashrc
mkdir -p .kube

export HOME="${sessiondir}"

admin_kubeconfig=${WEBKUBECTL_KUBECONFIG:-/etc/webkubectl/kubeconfig}
if [ ! -r "${admin_kubeconfig}" ]; then
	echo "No kubeconfig configured. An administrator must place a" \
		"kubeconfig at ${admin_kubeconfig} (readable by this" \
		"service's user) before webkubectl can reach a cluster."
	exit 1
fi
cp "${admin_kubeconfig}" .kube/config

if [ "${KUBECTL_INSECURE_SKIP_TLS_VERIFY}" = "true" ]; then
	clusters=$(kubectl config get-clusters | tail -n +2)
	for s in ${clusters}; do
		kubectl config set-cluster "${s}" --insecure-skip-tls-verify=true > /dev/null 2>&1 || true
		kubectl config unset clusters."${s}".certificate-authority-data > /dev/null 2>&1 || true
	done
fi

chown -R nobody:nogroup .kube

export TMPDIR="${sessiondir}"

for env_name in $(env | grep '^GOTTY' | cut -d= -f1); do
	unset "${env_name}"
done
unset WELCOME_BANNER PPROF_ENABLED KUBECTL_INSECURE_SKIP_TLS_VERIFY SESSION_STORAGE_SIZE WEBKUBECTL_KUBECONFIG

# Not exec'd: cleanup() above must still run once this returns.
su -s /bin/bash nobody
