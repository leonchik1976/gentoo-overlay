#!/bin/bash
# Adapted from upstream start-webkubectl.sh for Gentoo filesystem paths.
set -e

# GOTTY_OPTIONS arrives as a single systemd Environment= string (no
# native array support there), so it's split into a real argument
# array here rather than passed to gotty via bare ${GOTTY_OPTIONS}
# expansion -- unquoted expansion is both word- *and* pathname-split,
# so a value containing e.g. "*" would be glob-expanded against
# whatever matches in the current directory before gotty ever sees
# it. read -ra still splits on whitespace (systemd's own Environment=
# offers no per-token quoting to preserve here either), but does not
# perform pathname expansion.
read -ra gotty_options <<< "${GOTTY_OPTIONS}"
exec /usr/bin/gotty "${gotty_options[@]}" /usr/libexec/webkubectl/start-session.sh
