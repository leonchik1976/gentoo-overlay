# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he
	hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr
	sv sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Cross-platform SQL editor and database manager"
HOMEPAGE="https://www.beekeeperstudio.io/ https://github.com/beekeeper-studio/beekeeper-studio"
SRC_URI="
	amd64? (
		https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v${PV}/${MY_PN}_${PV}_arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

# The release combines GPL-3+ community code with commercially licensed code.
LICENSE="GPL-3+ Beekeeper-Studio-EULA-20260702"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/gnupg
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	elibc_glibc? ( sys-libs/glibc )
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libxshmfence
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/beekeeper-studio/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	pushd "opt/Beekeeper Studio/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	# Use Portage's setuid Chromium sandbox instead of upstream's launcher
	# default, which unconditionally disables sandboxing.
	local launcher="opt/Beekeeper Studio/beekeeper-studio"
	local upstream_exec='exec "$SCRIPT_DIR/beekeeper-studio-bin" "--no-sandbox" $USER_FLAGS "$@"'
	local sandboxed_exec='exec "$SCRIPT_DIR/beekeeper-studio-bin" $USER_FLAGS "$@"'
	grep -Fqx "${upstream_exec}" "${launcher}" ||
		die "Expected upstream launcher command not found; launcher layout changed"
	sed -i -e "s|^${upstream_exec}$|${sandboxed_exec}|" "${launcher}" || die
	grep -Fqx "${sandboxed_exec}" "${launcher}" ||
		die "Failed to enable the Chromium sandbox in the launcher command"
	if grep -E '^exec .*--no-sandbox' "${launcher}"; then
		die "Launcher command still disables the Chromium sandbox"
	fi

	# Launch via the stable command in PATH, independent of the /opt layout.
	sed -i \
		-e '/^Exec=/c Exec=beekeeper-studio %U' \
		-e '/^MimeType=/c MimeType=application/vnd.sqlite3;application/vnd.duckdb;x-scheme-handler/redshift;x-scheme-handler/cockroachdb;x-scheme-handler/cockroach;x-scheme-handler/mariadb;x-scheme-handler/tidb;x-scheme-handler/mysql;x-scheme-handler/postgresql;x-scheme-handler/postgres;x-scheme-handler/psql;x-scheme-handler/sqlite;x-scheme-handler/sqlserver;x-scheme-handler/microsoftsqlserver;x-scheme-handler/mssql;x-scheme-handler/redis;x-scheme-handler/rediss;' \
		usr/share/applications/beekeeper-studio.desktop || die
	gunzip usr/share/doc/beekeeper-studio/changelog.gz || die

	# The Node packages bundle native modules for several operating systems and
	# libc implementations.  Retain only the module usable by this package.
	local native_arch
	case ${ARCH} in
		amd64) native_arch=x64 ;;
		arm64) native_arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	local modules="opt/Beekeeper Studio/resources/app.asar.unpacked/node_modules"
	local msnodesqlv8="${modules}/msnodesqlv8"
	local oracle="${modules}/oracledb/build/Release"
	local snowflake="${modules}/snowflake-sdk/dist/lib/minicore/binaries"
	case ${ARCH} in
		amd64)
			[[ -d ${msnodesqlv8} ]] ||
				die "Expected amd64 msnodesqlv8 addon not found; upstream layout changed"
			rm -r "${msnodesqlv8}" || die
			;;
		arm64)
			[[ ! -e ${msnodesqlv8} ]] ||
				die "Unexpected arm64 msnodesqlv8 addon found; upstream layout changed"
			;;
	esac
	find "${oracle}" -type f -name '*.node' \
		! -name "*-linux-${native_arch}.node" -delete || die
	find "${snowflake}" -type f -name '*.node' \
		! -name "*.linux-${native_arch}-gnu.node" -delete || die
	rm -r "${modules}/@libsql/linux-${native_arch}-musl" || die
	rm "opt/Beekeeper Studio/resources/vendor/pagent.exe" || die
}

src_install() {
	local size
	for size in 16 24 32 48 64 96 128 256 512 1024; do
		doicon -s "${size}" \
			"usr/share/icons/hicolor/${size}x${size}/apps/beekeeper-studio.png"
	done
	domenu usr/share/applications/beekeeper-studio.desktop

	insinto /usr/share/mime/packages
	doins "${FILESDIR}"/beekeeper-studio.xml
	dodoc usr/share/doc/beekeeper-studio/changelog

	insinto /opt/beekeeper-studio
	doins -r "opt/Beekeeper Studio"/.

	fperms +x \
		/opt/beekeeper-studio/beekeeper-studio \
		/opt/beekeeper-studio/beekeeper-studio-bin \
		/opt/beekeeper-studio/chrome_crashpad_handler \
		/opt/beekeeper-studio/libEGL.so \
		/opt/beekeeper-studio/libGLESv2.so \
		/opt/beekeeper-studio/libffmpeg.so \
		/opt/beekeeper-studio/libvk_swiftshader.so \
		/opt/beekeeper-studio/libvulkan.so.1 \
		/opt/beekeeper-studio/resources/app.asar.unpacked/node_modules/snowflake-sdk/node_modules/open/xdg-open
	fperms 4755 /opt/beekeeper-studio/chrome-sandbox

	dosym ../../opt/beekeeper-studio/beekeeper-studio \
		/usr/bin/beekeeper-studio
}
