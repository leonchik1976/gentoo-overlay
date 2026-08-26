#!/bin/bash
# Adapted from upstream start-session.sh for Gentoo filesystem paths.
#
# Upstream's version required and forwarded caller-supplied arguments
# (a base64 kubeconfig or a server+token pair) to init-kubectl.sh.
# This package's unit disables gotty's caller-argument support
# (--permit-arguments=false in webkubectl.service) and init-kubectl.sh
# now sources cluster credentials from an administrator-provided
# kubeconfig instead, so there is nothing left to require or forward
# here.
set -e

exec unshare --fork --pid --mount-proc --mount /usr/libexec/webkubectl/init-kubectl.sh
