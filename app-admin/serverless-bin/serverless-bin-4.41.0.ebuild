# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Build and deploy applications on AWS Lambda and other managed cloud services"
HOMEPAGE="
	https://www.serverless.com/framework
	https://github.com/serverless/serverless
"

# The immutable, per-version archive uploaded by upstream's own release
# pipeline (.github/workflows/release-framework.yml -> prepareReleaseTars.sh,
# at git tag sf-core@4.41.0: `aws s3 cp ... s3://install.serverless.com/
# archives/serverless-${version}.tgz`). This is what upstream's own "serverless"
# npm installer stub and install.sh launcher both fetch and cache at
# ~/.serverless before exec'ing it; this ebuild fetches and installs that
# same archive directly instead of running either of those launchers, so no
# npm/curl network access happens in any phase, and nothing installed by
# this ebuild ever re-fetches or replaces itself. Verified: two separate
# downloads returned byte-identical content (sha256
# af06aaf9ba46e321fca2d1c1fa5dc89f471f754f0b0663dafdcba8a1bbe5e305).
SRC_URI="https://install.serverless.com/archives/serverless-${PV}.tgz -> ${P}.tgz"
S="${WORKDIR}/package"

# The archive is upstream's own proprietary build, distributed under the
# Serverless Customer Agreement (see licenses/Serverless-Customer-Agreement-
# 20251201), not an OSI license -- @serverless/framework being MIT upstream
# does not make the assembled CLI MIT, since it cannot run without the
# unlicensed @serverlessinc/sf-core and @serverless/engine packages it
# depends on. The archive itself carries no bundled LICENSE file to install;
# the license text here was transcribed separately from upstream's published
# agreement PDF for Portage's ACCEPT_LICENSE gate.
LICENSE="Serverless-Customer-Agreement-20251201"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Not fetch-restricted: the archive downloads anonymously over plain HTTPS
# with no auth/acceptance flow. mirror+bindist because redistribution of
# this proprietary payload, whether via the Gentoo mirror network or as a
# Gentoo binary package, is not authorized by the Agreement above. strip
# because the bundled binaries (esbuild's native launchers, the cpu-features/
# ssh2 addons) are upstream prebuilt artifacts we did not compile; leave them
# byte-for-byte as upstream shipped them rather than running Portage's strip
# pass over them.
RESTRICT="mirror bindist strip"

# Matches packages/sf-core-installer's engines.node from the same upstream
# release; this bundle's `dist/sf-core.js` needs the [ssl] USE flag for its
# own HTTPS/AWS API calls, same as dev-util/aws-cdk in this overlay.
RDEPEND=">=net-libs/nodejs-18.17.0[ssl]"
BDEPEND=">=net-libs/nodejs-18.17.0"

# Native addons bundled by upstream's own build (packages/sf-core/scripts/
# prepareDistributionTarballs.js): esbuild's per-platform binaries (needed so
# esbuild's own runtime can dispatch by process.platform/process.arch; do not
# prune the ones not matching ${ARCH} -- this is meant to stay upstream's
# complete, unmodified archive) plus two amd64-only native accelerators
# (cpu-features/ssh2) that fall back gracefully when absent/foreign-arch, per
# manual arm64 execution testing (see package report).
QA_PREBUILT="
	usr/libexec/${PN}/dist/*.node
	usr/libexec/${PN}/dist/node_modules/@esbuild/linux-x64/bin/esbuild
	usr/libexec/${PN}/dist/node_modules/@esbuild/linux-arm64/bin/esbuild
	usr/libexec/${PN}/dist/node_modules/@esbuild/darwin-x64/bin/esbuild
	usr/libexec/${PN}/dist/node_modules/@esbuild/darwin-arm64/bin/esbuild
"

# The two amd64-only addons above are dynamically linked against libc.so.6
# (confirmed via `file`); on arm64 that NEEDED entry is unresolvable against
# the host's own libc, which FEATURES=qa-unresolved-soname-deps flags at
# postinst as "QA Notice: Unresolved soname dependencies". This is expected
# and already accounted for -- both addons load with a graceful pure-JS
# fallback when their native binary is absent/foreign-arch (confirmed by
# actually running the CLI on arm64; see package report), and esbuild's own
# binaries are statically linked, so they carry no NEEDED entries and never
# trigger this check. Exclude only these two known files from soname
# REQUIRES generation, rather than disabling the QA class package-wide.
REQUIRES_EXCLUDE="
	usr/libexec/${PN}/dist/cpufeatures-*.node
	usr/libexec/${PN}/dist/sshcrypto-*.node
"

src_test() {
	local version

	version=$(node dist/sf-core.js --version 2>&1) || die "failed to run the packaged CLI"
	[[ ${version} == *"${PV}"* ]] ||
		die "unexpected Serverless Framework version: ${version}"
}

src_install() {
	local dir="/usr/libexec/${PN}"

	insinto "${dir}"
	doins package.json db.json.gz
	doins -r dist lib docs

	fperms +x \
		"${dir}"/dist/node_modules/@esbuild/linux-x64/bin/esbuild \
		"${dir}"/dist/node_modules/@esbuild/linux-arm64/bin/esbuild \
		"${dir}"/dist/node_modules/@esbuild/darwin-x64/bin/esbuild \
		"${dir}"/dist/node_modules/@esbuild/darwin-arm64/bin/esbuild
	[[ -e "${ED}${dir}"/dist/node_modules/@esbuild/win32-x64/esbuild.exe ]] &&
		fperms +x "${dir}"/dist/node_modules/@esbuild/win32-x64/esbuild.exe

	newbin "${FILESDIR}"/serverless serverless
	dosym serverless /usr/bin/sls
}

pkg_postinst() {
	elog "This package installs upstream's prebuilt, unmodified"
	elog "serverless-${PV}.tgz release archive and runs it directly with the"
	elog "system Node.js interpreter. It does not install or run Serverless's"
	elog "own npm installer stub or install.sh launcher, so nothing here"
	elog "downloads, updates, or replaces the installed CLI on its own; a"
	elog "newer Serverless Framework release means emerging a newer version"
	elog "of this package."
	elog ""
	elog "If a project's serverless.yml pins a different 'frameworkVersion',"
	elog "this CLI will hard-error (FRAMEWORK_VERSION_MISMATCH) rather than"
	elog "silently fetching a different version -- install the matching"
	elog "${PN} version through Portage instead."
	elog ""
	elog "Serverless Framework v4 is proprietary software under the"
	elog "Serverless Customer Agreement (see this overlay's licenses/"
	elog "Serverless-Customer-Agreement-20251201). Beyond --version/--help,"
	elog "most commands require a Serverless License Key or authentication"
	elog "against Serverless's SaaS Dashboard, and the Agreement mandates"
	elog "telemetry sharing unless a License Key permits disabling it; this"
	elog "package does not patch, disable, or work around license-key,"
	elog "authentication, or telemetry checks. \"Free User\" eligibility is"
	elog "defined in Section 1.9 of the Agreement (see this overlay's"
	elog "licenses/Serverless-Customer-Agreement-20251201) -- Section 1.9"
	elog "also requires this classification to be reassessed monthly, not"
	elog "just checked once. Determining and maintaining eligibility, and"
	elog "completing authentication, remain your responsibility."
}
