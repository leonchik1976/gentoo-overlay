# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature xdg

MY_PN="LocalStack-Desktop-community"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="LocalStack Desktop Community Electron application"
HOMEPAGE="https://github.com/localstack/localstack-desktop"
SRC_URI="https://github.com/localstack/localstack-desktop/releases/download/${PV}/${MY_P}.AppImage"

S="${WORKDIR}/squashfs-root"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/dbus-glib
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libdbusmenu
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
"

QA_PREBUILT="
	opt/localstack-desktop/chrome_crashpad_handler
	opt/localstack-desktop/chrome-sandbox
	opt/localstack-desktop/libEGL.so
	opt/localstack-desktop/libffmpeg.so
	opt/localstack-desktop/libGLESv2.so
	opt/localstack-desktop/libvk_swiftshader.so
	opt/localstack-desktop/libvulkan.so.1
	opt/localstack-desktop/localstackdesktop
	opt/localstack-desktop/swiftshader/libEGL.so
	opt/localstack-desktop/swiftshader/libGLESv2.so
	opt/localstack-desktop/usr/lib/libappindicator.so.1
	opt/localstack-desktop/usr/lib/libgconf-2.so.4
	opt/localstack-desktop/usr/lib/libindicator.so.7
	opt/localstack-desktop/usr/lib/libnotify.so.4
	opt/localstack-desktop/usr/lib/libXss.so.1
	opt/localstack-desktop/usr/lib/libXtst.so.6
"

src_unpack() {
	cp "${DISTDIR}/${MY_P}.AppImage" "${WORKDIR}/" || die
	chmod +x "${WORKDIR}/${MY_P}.AppImage" || die
	cd "${WORKDIR}" || die
	"./${MY_P}.AppImage" --appimage-extract || die
}

src_install() {
	local appdir="/opt/localstack-desktop"

	dodir "${appdir}"
	cp -a "${S}/." "${ED}${appdir}/" || die

	find "${ED}${appdir}" -type d -printf '/%P\0' |
	while IFS= read -r -d '' dir; do
		fperms 0755 "${appdir}${dir}"
	done

	rm -f \
		"${ED}${appdir}/.DirIcon" \
		"${ED}${appdir}/AppRun" \
		"${ED}${appdir}/localstackdesktop.desktop" \
		"${ED}${appdir}/localstackdesktop.png" || die
	rm -rf "${ED}${appdir}/usr/share/icons" || die

	cat > "${T}/localstack-desktop" <<-EOF || die
		#!/bin/sh
		APPDIR="${appdir}"
		export APPDIR
		export LD_LIBRARY_PATH="\${APPDIR}/usr/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
		exec "\${APPDIR}/localstackdesktop" --no-sandbox "\$@"
	EOF
	dobin "${T}/localstack-desktop"

	sed \
		-e 's|^Exec=.*|Exec=/usr/bin/localstack-desktop %U|' \
		-e '/^X-AppImage-Version=/d' \
		"${S}/localstackdesktop.desktop" > "${T}/localstackdesktop.desktop" || die
	domenu "${T}/localstackdesktop.desktop"

	local icon size
	for icon in "${S}"/usr/share/icons/hicolor/*/apps/localstackdesktop.png; do
		size=${icon%/apps/localstackdesktop.png}
		size=${size##*/}
		doicon -s "${size%x*}" "${icon}"
	done
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LocalStack Desktop Community is installed from the upstream amd64 AppImage"
	elog "and runs from /opt/localstack-desktop without a runtime FUSE dependency."
	elog
	elog "The bundled application contains an auto-updater. This ebuild does not"
	elog "disable it; update this package through Portage instead of the in-app"
	elog "updater to keep the local overlay state authoritative."
	elog
	elog "The bundled Community application sends operational telemetry to"
	elog "LocalStack services and uses LocalStack cloud authentication for some"
	elog "features. This ebuild leaves that upstream behavior unchanged."
	elog
	optfeature "managing LocalStack containers through the Docker daemon" app-containers/docker
}
