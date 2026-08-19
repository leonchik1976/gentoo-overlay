# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# cmake.eclass only supports EAPI 8; xdg.eclass supports up to 8 as well.
EAPI=8

inherit cmake xdg

DESCRIPTION="User-friendly tool for creating bootable media for Raspberry Pi devices"
HOMEPAGE="
	https://www.raspberrypi.com/software/
	https://github.com/raspberrypi/rpi-imager
"

# Upstream statically links curl, zlib, libarchive, xz(liblzma), zstd,
# nghttp2 and libusb, fetched at CMake-configure time as separate git
# repositories via FetchContent (src/dependencies/vendor/<name>, see
# src/dependencies/fetch-vendor.cmake and src/dependencies/*.cmake).
# There is no upstream option to use system copies of these instead: the
# CMake code hardcodes a heavily trimmed, statically-linked, GnuTLS-backed
# curl build (most protocols/auth methods disabled) and static
# zlib/libarchive/zstd/xz/nghttp2 tuned to match it. Re-plumbing all of that
# to system libraries would diverge substantially from what upstream builds
# and tests. To keep the build fully offline (no network access during
# src_compile, per repository policy) each vendored dependency is instead
# fetched here, pinned to the exact commit the v${PV} submodules point at,
# and copied into place in src_prepare so FetchContent's vendor-detection
# finds it locally instead of trying to fetch it.
RPI_IMAGER_CURL_COMMIT="a05f34973e6c4bb629d018f7cb51487be1c904d8"
RPI_IMAGER_ZLIB_COMMIT="da607da739fa6047df13e66a2af6b8bec7c2a498"
RPI_IMAGER_LIBARCHIVE_COMMIT="ded82291ab41d5e355831b96b0e1ff49e24d8939"
RPI_IMAGER_XZ_COMMIT="4b73f2ec19a99ef465282fbce633e8deb33691b3"
RPI_IMAGER_ZSTD_COMMIT="f8745da6ff1ad1e7bab384bd1f9d742439278e99"
RPI_IMAGER_NGHTTP2_COMMIT="68cb6900fde14c77f0cd7add0e094a862960eb99"
RPI_IMAGER_LIBUSB_COMMIT="87a55632db62c9bdc58cd31d3ccfa673f1bb017f"

SRC_URI="
	https://github.com/raspberrypi/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/curl/curl/archive/${RPI_IMAGER_CURL_COMMIT}.tar.gz
		-> ${PN}-curl-${RPI_IMAGER_CURL_COMMIT}.tar.gz
	https://github.com/madler/zlib/archive/${RPI_IMAGER_ZLIB_COMMIT}.tar.gz
		-> ${PN}-zlib-${RPI_IMAGER_ZLIB_COMMIT}.tar.gz
	https://github.com/libarchive/libarchive/archive/${RPI_IMAGER_LIBARCHIVE_COMMIT}.tar.gz
		-> ${PN}-libarchive-${RPI_IMAGER_LIBARCHIVE_COMMIT}.tar.gz
	https://github.com/tukaani-project/xz/archive/${RPI_IMAGER_XZ_COMMIT}.tar.gz
		-> ${PN}-xz-${RPI_IMAGER_XZ_COMMIT}.tar.gz
	https://github.com/facebook/zstd/archive/${RPI_IMAGER_ZSTD_COMMIT}.tar.gz
		-> ${PN}-zstd-${RPI_IMAGER_ZSTD_COMMIT}.tar.gz
	https://github.com/nghttp2/nghttp2/archive/${RPI_IMAGER_NGHTTP2_COMMIT}.tar.gz
		-> ${PN}-nghttp2-${RPI_IMAGER_NGHTTP2_COMMIT}.tar.gz
	https://github.com/libusb/libusb/archive/${RPI_IMAGER_LIBUSB_COMMIT}.tar.gz
		-> ${PN}-libusb-${RPI_IMAGER_LIBUSB_COMMIT}.tar.gz
"
S="${WORKDIR}/${P}/src"

# Main application: Apache-2.0 (src/../license.txt). Statically-linked
# vendored components pulled in via SRC_URI above (see the long comment
# above): libcurl is "curl", libarchive is BSD, zlib is ZLIB, xz/liblzma is
# 0BSD, zstd is BSD, nghttp2 is MIT, libusb is LGPL-2.1. The in-tree (not
# separately fetched) yescrypt and drivelist helpers are BSD-2 and
# Apache-2.0 respectively.
LICENSE="Apache-2.0"
LICENSE+=" curl BSD ZLIB 0BSD MIT LGPL-2.1 BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# GnuTLS/idn2/nettle, Qt and libudev are linked dynamically against the
# system copies; util-linux's lsblk is both a configure-time check
# (src/linux/PlatformPackaging.cmake) and used at runtime to enumerate
# block devices.
RDEPEND="
	dev-libs/nettle:=
	dev-qt/qtbase:6[dbus,gui,network]
	dev-qt/qtdeclarative:6
	dev-qt/qtsvg:6
	net-dns/libidn2:=
	net-libs/gnutls:=
	sys-apps/util-linux
	sys-auth/polkit
	sys-fs/dosfstools
	sys-libs/liburing
	virtual/libudev
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	sys-apps/util-linux
	virtual/pkgconfig
"

src_prepare() {
	cmake_src_prepare

	local -A vendor_dirs=(
		[curl]="curl-${RPI_IMAGER_CURL_COMMIT}"
		[zlib]="zlib-${RPI_IMAGER_ZLIB_COMMIT}"
		[libarchive]="libarchive-${RPI_IMAGER_LIBARCHIVE_COMMIT}"
		[xz]="xz-${RPI_IMAGER_XZ_COMMIT}"
		[zstd]="zstd-${RPI_IMAGER_ZSTD_COMMIT}"
		[nghttp2]="nghttp2-${RPI_IMAGER_NGHTTP2_COMMIT}"
		[libusb]="libusb-${RPI_IMAGER_LIBUSB_COMMIT}"
	)

	local name
	for name in "${!vendor_dirs[@]}"; do
		mkdir -p "${S}/dependencies/vendor/${name}" || die
		mv "${WORKDIR}/${vendor_dirs[${name}]}"/* \
			"${S}/dependencies/vendor/${name}/" || die
	done
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_EMBEDDED=OFF
		-DBUILD_CLI_ONLY=OFF
		-DBUILD_TESTING=OFF
		# Both of these default to ON and try to download fresh reference
		# data (IANA tzdata / kernel.org wireless-regdb) at build time; the
		# generator scripts fall back to the bundled timezones.txt /
		# countries.txt when offline, but disable them outright so the
		# build never attempts network access in the first place.
		-DGENERATE_TIMEZONES_FROM_IANA=OFF
		-DGENERATE_COUNTRIES_FROM_REGDB=OFF
		# Deliberate distro-packaging defaults, not an upstream default:
		# don't phone home for update checks or send telemetry. Users can
		# still re-enable both at runtime from within the app's settings.
		-DENABLE_TELEMETRY=OFF
		-DENABLE_CHECK_VERSION=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Only asset the CMake install() rules (src/linux/PlatformPackaging.cmake)
	# don't cover; everything else (binary, icon, desktop file, metainfo.xml,
	# udev rules) is already installed by cmake_src_install above.
	insinto /usr/share/polkit-1/actions
	doins "${WORKDIR}/${P}/debian/com.raspberrypi.rpi-imager.policy"
}
