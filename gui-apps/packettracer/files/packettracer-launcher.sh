#!/bin/sh
# Launches Cisco's bundled Qt6/QtWebEngine PacketTracer binary.
#
# Upstream ships this as an AppImage whose AppRun script builds
# LD_LIBRARY_PATH from the app's own bin/ directory plus a small set of
# ABI-compat shim libraries (e.g. libtiff.so.5, libpcre2-16.so.0) bundled
# alongside it for distros that no longer ship those exact SONAMEs. This
# wrapper reproduces that behaviour for the extracted (non-AppImage) install.
PTDIR=/opt/pt

export LD_LIBRARY_PATH="${PTDIR}/bin:${PTDIR}/compat-lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-auto}"

cd "${PTDIR}/bin" || exit 1
exec ./PacketTracer "$@"
