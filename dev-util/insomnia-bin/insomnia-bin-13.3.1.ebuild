# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="HTTP, GraphQL, and gRPC client for developers"
HOMEPAGE="https://insomnia.rest https://github.com/Kong/insomnia"
SRC_URI="https://github.com/Kong/insomnia/releases/download/core@${PV}/Insomnia.Core-${PV}.deb"
S="${WORKDIR}"

# Includes the licenses of the bundled Electron runtime and JavaScript modules.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT MIT-0 BSD BSD-2
	0BSD ISC BlueOak-1.0.0 Boost-1.0 CC-BY-3.0 CC-BY-4.0 CC0-1.0
	MPL-1.1 MPL-2.0 Ms-PL PSF-2 Unlicense GPL-2 LGPL-2 LGPL-2.1 LGPL-3
	FFT2D FTL IJG SGI-B-2.0 SunSoft UoI-NCSA ZLIB libpng2 libtiff
	Unicode-3.0 Unicode-DFS-2015 Unicode-DFS-2016 GSAP-Standard"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+abi_x86_64"
REQUIRED_USE="elibc_glibc abi_x86_64"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=sys-libs/glibc-2.34
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"
BDEPEND="${BDEPEND}
	app-arch/xz-utils
	dev-util/patchelf
"

QA_PREBUILT="opt/Insomnia/*"
# These are optional GPU backends; node-llama-cpp detects them and falls back
# to its bundled CPU backend when the driver/runtime is unavailable.
REQUIRES_EXCLUDE="libcuda.so.1 libcudart.so.12 libcudart.so.13
	libcublas.so.12 libcublas.so.13"

src_prepare() {
	default
	local modules=opt/Insomnia/resources/app.asar.unpacked/node_modules
	rm -r "${modules}"/@node-llama-cpp/linux-{arm64,armv7l} \
		"${modules}"/@reflink/reflink-linux-x64-musl || die
	# Remove empty search entries and upstream's build-machine paths while
	# preserving the relative paths used to load the bundled AI backends.
	local library rpath
	while IFS= read -r -d '' library; do
		rpath=$(patchelf --print-rpath "${library}") || die
		rpath=${rpath//:\/opt\/vulkan-sdk\/x86_64\/lib/}
		rpath=${rpath%:}
		patchelf --set-rpath "${rpath}" "${library}" || die
	done < <(find "${modules}"/@node-llama-cpp \
		\( -name '*.so' -o -name '*.node' \) -print0)
	patchelf --remove-rpath \
		"${modules}"/@getinsomnia/node-libcurl/lib/binding/node_libcurl.node || die
	sed -i 's|^Exec=.*|Exec=insomnia %U|' \
		usr/share/applications/insomnia.desktop || die
}

src_install() {
	local size
	for size in 16 24 32 48 64 128 256 512; do
		doicon -s "${size}" usr/share/icons/hicolor/"${size}x${size}"/apps/insomnia.png
	done
	dosym -r /usr/share/icons/hicolor/512x512/apps/insomnia.png \
		/usr/share/pixmaps/insomnia.png
	domenu usr/share/applications/insomnia.desktop

	insinto /opt/Insomnia
	doins -r opt/Insomnia/.
	fperms +x /opt/Insomnia/{insomnia,chrome_crashpad_handler}
	fperms +x /opt/Insomnia/resources/bin/yarn-standalone.js
	dosym -r /opt/Insomnia/insomnia /usr/bin/insomnia
	gzip -dc usr/share/doc/insomnia/changelog.gz > "${T}/changelog" || die
	dodoc "${T}/changelog"
}
