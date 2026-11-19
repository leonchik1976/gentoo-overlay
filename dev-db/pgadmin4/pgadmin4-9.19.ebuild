# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )
PYTHON_REQ_USE="sqlite"
inherit desktop python-single-r1 xdg

DESCRIPTION="Desktop administration and development tools for PostgreSQL"
HOMEPAGE="https://www.pgadmin.org/"
ELECTRON_VERSION=44.7.0
YARN_VERSION=4.15.0
UPSTREAM_URI="https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PV}"
ELECTRON_URI="https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}"
SRC_URI="
	fetch+${UPSTREAM_URI}/source/${P}.tar.gz
	fetch+${UPSTREAM_URI}/pip/${P}-py3-none-any.whl
	fetch+https://registry.npmjs.org/@yarnpkg/cli-dist/-/cli-dist-${YARN_VERSION}.tgz
		-> yarn-cli-dist-${YARN_VERSION}.tgz
	amd64? ( fetch+${ELECTRON_URI}/electron-v${ELECTRON_VERSION}-linux-x64.zip )
	arm64? ( fetch+${ELECTRON_URI}/electron-v${ELECTRON_VERSION}-linux-arm64.zip )
	${P}-yarn-cache.tar
"

# Application, bundled browser and desktop assets, and Electron/Chromium.
LICENSE="POSTGRESQL MIT Apache-2.0 Apache-2.0-with-LLVM-exceptions
	BSD BSD-2 Hippocratic-2.1 ISC
	Boost-1.0 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0 EPL-2.0 FFT2D FTL IJG
	LGPL-2 LGPL-2.1+ MPL-2.0 OFL-1.1 PSF-2 Unicode-3.0 Unicode-DFS-2016 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE} elibc_glibc"
RESTRICT="bindist fetch mirror test"

BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	app-arch/xz-utils
	>=net-libs/nodejs-24
	$(python_gen_cond_dep 'dev-python/babel[${PYTHON_USEDEP}]')
"
RDEPEND="
	${PYTHON_DEPS}
	app-accessibility/at-spi2-core
	dev-db/postgresql:*
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	>=sys-libs/glibc-2.25
	virtual/udev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
	$(python_gen_cond_dep '
		>=dev-python/azure-identity-1.26.0[${PYTHON_USEDEP}]
		>=dev-python/azure-mgmt-rdbms-10.1.1[${PYTHON_USEDEP}]
		>=dev-python/azure-mgmt-resource-24.0.0[${PYTHON_USEDEP}]
		<dev-python/azure-mgmt-resource-26[${PYTHON_USEDEP}]
		>=dev-python/azure-mgmt-subscription-3.1.1[${PYTHON_USEDEP}]
		dev-python/bcrypt[${PYTHON_USEDEP}]
		dev-python/boto3[${PYTHON_USEDEP}]
		dev-python/certifi[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/flask[${PYTHON_USEDEP}]
		dev-python/flask-babel[${PYTHON_USEDEP}]
		dev-python/flask-compress[${PYTHON_USEDEP}]
		dev-python/flask-login[${PYTHON_USEDEP}]
		dev-python/flask-mail[${PYTHON_USEDEP}]
		dev-python/flask-migrate[${PYTHON_USEDEP}]
		dev-python/flask-paranoid[${PYTHON_USEDEP}]
		>=dev-python/flask-security-too-5.8.3[${PYTHON_USEDEP}]
		<dev-python/flask-security-too-5.9[${PYTHON_USEDEP}]
		>=dev-python/flask-socketio-5.7[${PYTHON_USEDEP}]
		dev-python/flask-sqlalchemy[${PYTHON_USEDEP}]
		>=dev-python/flask-wtf-1.3[${PYTHON_USEDEP}]
		dev-python/google-api-python-client[${PYTHON_USEDEP}]
		dev-python/google-auth-oauthlib[${PYTHON_USEDEP}]
		dev-python/jsonformatter[${PYTHON_USEDEP}]
		dev-python/keyring[${PYTHON_USEDEP}]
		dev-python/libgravatar[${PYTHON_USEDEP}]
		dev-python/paramiko[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/psycopg-3.3.6[native-extensions,${PYTHON_USEDEP}]
		dev-python/pyotp[${PYTHON_USEDEP}]
		<dev-python/python-dateutil-5[${PYTHON_USEDEP}]
		dev-python/pytz[${PYTHON_USEDEP}]
		dev-python/qrcode[${PYTHON_USEDEP}]
		dev-python/secretstorage[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/sqlparse[${PYTHON_USEDEP}]
		dev-python/sshtunnel[${PYTHON_USEDEP}]
		dev-python/typer[${PYTHON_USEDEP}]
		dev-python/urllib3[${PYTHON_USEDEP}]
		dev-python/user-agents[${PYTHON_USEDEP}]
		dev-python/werkzeug[${PYTHON_USEDEP}]
		dev-python/wtforms[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="
	opt/pgadmin4/bin/pgadmin4
	opt/pgadmin4/bin/chrome-sandbox
	opt/pgadmin4/bin/chrome_crashpad_handler
	opt/pgadmin4/bin/*.so*
"

pkg_nofetch() {
	einfo "Generate ${P}-yarn-cache.tar using scripts/generate-pgadmin4-yarn-cache.sh."
	einfo "Pass the ${P}.tar.gz source archive to the script and place its output in DISTDIR."
}

src_unpack() {
	local electron_arch=x64
	use arm64 && electron_arch=arm64
	unpack "${P}.tar.gz" "${P}-yarn-cache.tar" "yarn-cli-dist-${YARN_VERSION}.tgz"

	unzip -q "${DISTDIR}/electron-v${ELECTRON_VERSION}-linux-${electron_arch}.zip" 		-d "${WORKDIR}/electron" || die
	# The release wheel supplies the same offline HTML help shipped upstream.
	unzip -q "${DISTDIR}/${P}-py3-none-any.whl" 'pgadmin4/docs/en_US/_build/html/*' 		-d "${WORKDIR}/help" || die
}

src_prepare() {
	default

	local project
	for project in web runtime; do
		mkdir -p "${project}/.yarn" || die
		mv "${WORKDIR}/yarn-cache/${project}" "${project}/.yarn/cache" || die
	done

	printf '%s\n' '' 'supportedArchitectures:' '  os: [linux]' \
		'  cpu: [x64, arm64]' '  libc: [glibc]' >> web/.yarnrc.yml || die
	sed -e 's@../../../share/docs/en_US/html/@../../../help/@' \
		-e "s@/usr/bin@${EPREFIX}/usr/bin@" pkg/linux/config_distro.py > web/config_distro.py || die
}

src_compile() {
	export YARN_ENABLE_GLOBAL_CACHE=false YARN_ENABLE_NETWORK=false
	export YARN_ENABLE_SCRIPTS=false YARN_ENABLE_TELEMETRY=0
	export YARN_ENABLE_IMMUTABLE_CACHE=true YARN_ENABLE_PROGRESS_BARS=false

	local yarn=( node "${WORKDIR}/package/bin/yarn.js" )
	pushd web >/dev/null || die
	"${yarn[@]}" install --immutable --mode=skip-build || die
	# The linter is separate from generating the production assets.
	NODE_ENV=production NODE_OPTIONS=--max-old-space-size=3072 		"${yarn[@]}" run webpacker || die
	"${EPYTHON}" -m babel.messages.frontend compile -d pgadmin/translations || die
	popd >/dev/null || die

	pushd runtime >/dev/null || die
	"${yarn[@]}" workspaces focus --production || die
	popd >/dev/null || die
}

src_install() {
	local appdir=/opt/pgadmin4
	local electron="${WORKDIR}/electron"
	local image_help="${WORKDIR}/help/pgadmin4/docs/en_US/_build/html"

	insinto "${appdir}/bin"
	doins -r "${electron}"/.
	exeinto "${appdir}/bin"
	newexe "${electron}/electron" pgadmin4
	doexe "${electron}"/{chrome-sandbox,chrome_crashpad_handler}
	rm "${ED}${appdir}/bin/electron" || die
	fperms 4711 "${appdir}/bin/chrome-sandbox"

	insinto "${appdir}/bin/resources/app"
	doins -r runtime/{assets,src,node_modules,package.json}
	rm -rf "${ED}${appdir}/bin/resources/app/node_modules"/{.bin,.yarn-state.yml} || die

	insinto "${appdir}/web"
	doins -r web/{*.py,commit_hash,migrations,pgacloud,pgadmin}
	find "${ED}${appdir}/web" -type d \( -name tests -o -name __pycache__ -o -name .cache \) \
		-prune -exec rm -r {} + || die
	python_optimize "${ED}${appdir}/web"
	insinto "${appdir}/help"
	doins -r "${image_help}"/.

	dosym -r "/usr/bin/${EPYTHON}" "${appdir}/venv/bin/python3"
	dosym -r "${appdir}/bin/pgadmin4" /usr/bin/pgadmin4
	make_desktop_entry --eapi9 --name 'pgAdmin 4' --categories 'Development;Database;' pgadmin4

	local size
	for size in 16 32 48 64 128; do
		newicon -s "${size}" "pkg/linux/pgadmin4-${size}x${size}.png" pgadmin4.png
	done
	dodoc LICENSE
	local notice
	for notice in "${P}"-{browser,desktop}-notices.txt; do
		xz -dc "${FILESDIR}/${notice}.xz" > "${T}/${notice}" || die
		dodoc "${T}/${notice}"
	done
}
