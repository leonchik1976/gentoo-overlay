# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python-single-r1 supports EAPI 7/8; the release wheels support Python 3.10–3.14.
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit python-single-r1

DESCRIPTION="Lightweight static analysis, packaged from the official prebuilt PyPI wheel"
HOMEPAGE="
	https://semgrep.dev/
	https://github.com/semgrep/semgrep/
	https://pypi.org/project/semgrep/
"

# Exact release wheels from https://pypi.org/pypi/semgrep/1.180.0/json.
# Supplementary archives/RPMs provide documents only; RPM binaries are ignored.
SRC_URI="
	amd64? (
		https://files.pythonhosted.org/packages/7c/1f/f4af9cc92651f04ab973eac214a62ed23260da9e0696c105b4b9734da453/semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_x86_64.whl
	)
	arm64? (
		https://files.pythonhosted.org/packages/38/60/66135de6020e792491b0973d95efc89ef729a38c58106394b2798bf58dda/semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_aarch64.whl
	)
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/LICENSE
		-> ${P}-semgrep-LICENSE
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semdep/external/parsy/LICENSE
		-> ${P}-parsy-LICENSE
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semdep/external/packaging/LICENSE
		-> ${P}-packaging-LICENSE
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semdep/external/packaging/LICENSE.APACHE
		-> ${P}-packaging-LICENSE.APACHE
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semdep/external/packaging/LICENSE.BSD
		-> ${P}-packaging-LICENSE.BSD
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semgrep/semgrep_interfaces/LICENSE
		-> ${P}-interfaces-LICENSE
	https://raw.githubusercontent.com/semgrep/semgrep/v${PV}/cli/src/semgrep/semgrep_interfaces/NOTICE
		-> ${P}-interfaces-NOTICE
	https://raw.githubusercontent.com/tree-sitter/tree-sitter/v0.26.3/LICENSE
		-> tree-sitter-0.26.3-LICENSE
	https://codeload.github.com/semgrep/semgrep/tar.gz/refs/tags/v${PV}
		-> semgrep-${PV}-source.tar.gz
	https://github.com/Chris00/ANSITerminal/releases/download/0.8.5/ANSITerminal-0.8.5.tbz
	https://erratique.ch/software/bos/releases/bos-0.3.0.tbz
	https://github.com/mirage/ca-certs/releases/download/v1.0.3/ca-certs-1.0.3.tbz
	https://github.com/ocaml-community/calendar/archive/refs/tags/v3.0.0.tar.gz
		-> calendar-3.0.0.gh.tar.gz
	https://erratique.ch/software/fmt/releases/fmt-0.11.0.tbz
	https://gitlab.inria.fr/fpottier/menhir/-/archive/20230608/archive.tar.gz
		-> menhir-20230608.tar.gz
	https://github.com/OCamlPro/ocplib-endian/archive/refs/tags/1.2.tar.gz
		-> ocplib-endian-1.2.gh.tar.gz
	https://github.com/ocaml-multicore/ocaml-uring/releases/download/v0.9/uring-0.9.tbz
	https://erratique.ch/software/uucp/releases/uucp-17.0.0.tbz
	https://erratique.ch/software/uutf/releases/uutf-1.0.4.tbz
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/bzip2-libs-1.0.8-11.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libcom_err-1.46.5-8.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/openssl-libs-3.5.8-1.el9_8.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libcurl-minimal-7.76.1-40.el9_8.7.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/elfutils-libs-0.194-1.el9.alma.1.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/elfutils-libelf-0.194-1.el9.alma.1.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libev-4.33-6.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libgcc-11.5.0-14.el9.alma.1.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/gmp-6.2.0-13.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/krb5-libs-1.21.1-10.el9_8.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/keyutils-libs-1.6.3-1.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/xz-libs-5.2.5-8.el9_0.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/glibc-2.34-275.el9_8.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libnghttp2-1.43.0-6.el9_8.2.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libselinux-3.6-3.el9.x86_64.rpm
	https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/Packages/l/libunwind-1.8.0-4.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/zlib-1.2.11-40.el9.x86_64.rpm
	https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/libzstd-1.5.5-1.el9.x86_64.rpm
	https://vault.almalinux.org/9.8/BaseOS/Source/Packages/keyutils-1.6.3-1.el9.src.rpm
	https://vault.almalinux.org/9.8/BaseOS/Source/Packages/glibc-2.34-275.el9_8.src.rpm
	https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2
"
S="${WORKDIR}"

# The wheel declares LGPL-2.1-or-later for Semgrep and bundles native libraries.
# Code, rodata and build IDs match official distro RPMs for 25 libraries
# per architecture; dynamic linking metadata differs. Static core attribution
# and the tree-sitter binary still lack a complete upstream attestation.
# The public release build pins unpatched tree-sitter 0.26.3 (MIT).
# Restore fetched, Manifest-tracked component notices omitted from the wheels.
# The installed audit documents corresponding-source/relinking requirements.
# INCOMPLETE: static inputs, grammar scope and exact LGPL grants await upstream.
LICENSE="
	LGPL-2.1+
	BZIP2
	CC0-1.0
	HPND
	ISC
	LGPL-2+
	LGPL-2-with-linking-exception
	LGPL-3-with-linking-exception
	Apache-2.0
	BSD
	curl
	|| ( GPL-2+ LGPL-3+ )
	|| ( BSD GPL-2+ )
	|| ( libgcc libstdc++ gcc-runtime-library-exception-3.1 )
	|| ( LGPL-3+ GPL-2+ )
	MIT
	LGPL-2.1
	public-domain
	ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# The manylinux wheels require glibc; ELIBC is supplied by the profile.
REQUIRED_USE="elibc_glibc ${PYTHON_REQUIRED_USE}"

# Verified empirically (see the packaging report): running Portage's
# default `strip --strip-unneeded` against the pristine semgrep-core
# executable corrupts its dynamic symbol-versioning information and
# makes it fail with "no version information available" / a blank
# "symbol lookup error" for every dynamic dependency, even though the
# unstripped (or patchelf-only-modified) binary runs fine. QA_PREBUILT
# below only suppresses QA *warnings* for these files, it does not
# stop Portage from stripping them, so RESTRICT=strip is required too.
RESTRICT="mirror strip"

# Keep weak blockers against overlapping source/core packages, even though
# those atoms are absent from the current gentoo/guru/local scan context.
# Preserve the exact release's dependency windows, except for the tested
# downstream baseline: Click 8.5.0 and OTel 1.45.1/0.66b1. Upstream still
# declares Click ~=8.4.2 and OTel ~=1.37.0/~=0.58b0; these overrides are
# local compatibility choices, not upstream-supported bounds. Keep installed
# METADATA aligned in src_prepare. The bundled libgcc requires GLIBC_2.35.
RDEPEND="
	>=sys-libs/glibc-2.35
	${PYTHON_DEPS}
	!dev-util/semgrep
	!dev-util/semgrep-core
	$(python_gen_cond_dep '
		>=dev-python/attrs-21.3[${PYTHON_USEDEP}]
		>=dev-python/boltons-21.0[${PYTHON_USEDEP}]
		<dev-python/boltons-22[${PYTHON_USEDEP}]
		>=dev-python/click-option-group-0.5[${PYTHON_USEDEP}]
		<dev-python/click-option-group-1[${PYTHON_USEDEP}]
		~dev-python/click-8.5.0[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.0[${PYTHON_USEDEP}]
		<dev-python/colorama-0.5[${PYTHON_USEDEP}]
		>=dev-python/exceptiongroup-1.2.0[${PYTHON_USEDEP}]
		<dev-python/exceptiongroup-1.3[${PYTHON_USEDEP}]
		>=dev-python/glom-23.3[${PYTHON_USEDEP}]
		>=dev-python/jsonschema-4.25.1[${PYTHON_USEDEP}]
		<dev-python/jsonschema-4.26[${PYTHON_USEDEP}]
		~dev-python/mcp-1.29.0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-api-1.45.1[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-sdk-1.45.1[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-exporter-otlp-proto-http-1.45.1[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-exporter-otlp-proto-http-1.45.1-r1[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-instrumentation-requests-0.66_beta1[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-instrumentation-threading-0.66_beta1[${PYTHON_USEDEP}]
		>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
		>=dev-python/peewee-3.14[${PYTHON_USEDEP}]
		<dev-python/peewee-4[${PYTHON_USEDEP}]
		>=dev-python/pyjwt-2.15.0[${PYTHON_USEDEP}]
		<dev-python/pyjwt-3[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		>=dev-python/requests-2.22[${PYTHON_USEDEP}]
		<dev-python/requests-3[${PYTHON_USEDEP}]
		>=dev-python/rich-13.5.2[${PYTHON_USEDEP}]
		>=dev-python/ruamel-yaml-0.18.15[${PYTHON_USEDEP}]
		~dev-python/ruamel-yaml-clib-0.2.15[${PYTHON_USEDEP}]
		>=dev-python/semantic-version-2.10.0[${PYTHON_USEDEP}]
		<dev-python/semantic-version-2.11[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.2[${PYTHON_USEDEP}]
		<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
		>=dev-python/urllib3-2.0[${PYTHON_USEDEP}]
		<dev-python/urllib3-3[${PYTHON_USEDEP}]
		>=dev-python/wcmatch-8.3[${PYTHON_USEDEP}]
		<dev-python/wcmatch-9[${PYTHON_USEDEP}]
	')
"
BDEPEND+="
	app-arch/libarchive[bzip2,lzma,zstd]
	app-arch/unzip
	dev-util/patchelf
"

# The wheel bundles a prebuilt native semgrep-core executable and its
# own vendored .so libraries (semgrep/bin/libs/*); they are
# intentionally preserved other than
# repairing the stale build-host RUNPATH entry below. Do not let
# QA machinery try to "fix" them further.
QA_PREBUILT="
	usr/lib/python*/site-packages/semgrep/bin/semgrep-core
	usr/lib/python*/site-packages/semgrep/bin/libs/*
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_unpack() {
	local wheel="semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_$(usex amd64 x86_64 aarch64).whl"
	unzip -q "${DISTDIR}/${wheel}" -d "${S}" || die
	"${PYTHON}" "${FILESDIR}/extract-notices.py" "${DISTDIR}" \
		"${FILESDIR}/semgrep-${PV}-notice-index.json" "${WORKDIR}/notices" || die
}

src_prepare() {
	default

	# Split the native binary + its bundled libs out of the pure
	# Python package tree so they can be installed with correct
	# executable permissions (python_domodule forces 0644, which
	# would leave semgrep-core non-executable) and a repaired RUNPATH.
	#
	# native/ lives under ${WORKDIR}, which -- unlike a plain shell
	# variable -- is a stable, deterministic path recomputed identically
	# in every phase (including when phases run as separate "ebuild"
	# invocations in fresh processes), so src_install() below derives
	# the same path again rather than relying on a global set here.
	# All selected Python targets provide stdlib tomllib. Keep the installed
	# wheel metadata consistent with the patched Poetry parser.
	sed -i -e 's/^import tomli$/import tomllib/' \
		-e 's/tomli\.loads/tomllib.loads/g' \
		-e 's/TOML parser (tomli)/TOML parser (tomllib)/' \
		"${S}/semgrep-${PV}.data/purelib/semdep/parsers/poetry.py" || die
	sed -i '/^Requires-Dist: tomli[ (<>=!~;]/d' \
		"${S}/semgrep-${PV}.dist-info/METADATA" || die

	# Tested downstream compatibility baseline; upstream bounds remain narrower.
	sed -i \
		-e 's/^Requires-Dist: click~=8\.4\.2$/Requires-Dist: click==8.5.0/' \
		-e 's/^Requires-Dist: \(opentelemetry-.*\)~=1\.37\.0$/Requires-Dist: \1==1.45.1/' \
		-e 's/^Requires-Dist: \(opentelemetry-.*\)~=0\.58b0$/Requires-Dist: \1==0.66b1/' \
		"${S}/semgrep-${PV}.dist-info/METADATA" || die

	local pkgdir="${S}/semgrep-${PV}.data/purelib/semgrep"
	local native_dir="${WORKDIR}/native"
	mkdir -p "${native_dir}" || die
	mv "${pkgdir}/bin/semgrep-core" "${native_dir}/" || die
	mv "${pkgdir}/bin/libs" "${native_dir}/libs" || die

	# Original RUNPATH (both amd64 and arm64 builds):
	#   /src/semgrep-pro/OSS/libs/ocaml-tree-sitter-core/tree-sitter/lib:$ORIGIN/libs
	# The first entry is a stale absolute path from Semgrep Inc.'s
	# private build environment; it never resolves on any Gentoo
	# system and must not be shipped. $ORIGIN/libs is the only entry
	# that is actually needed (it is how semgrep-core finds its own
	# bundled libs/ directory at runtime) and must be preserved.
	patchelf --set-rpath '$ORIGIN/libs' "${native_dir}/semgrep-core" || die
}

src_install() {
	# Recomputed independently of src_prepare(); see the comment there.
	local native_dir="${WORKDIR}/native"

	python_domodule "${S}/semgrep-${PV}.data/purelib/semdep"
	python_domodule "${S}/semgrep-${PV}.data/purelib/semgrep"

	local sitedir=$(python_get_sitedir)
	local bindir=${sitedir#"${EPREFIX}"}/semgrep/bin

	exeinto "${bindir}"
	doexe "${native_dir}/semgrep-core"

	exeinto "${bindir}/libs"
	doexe "${native_dir}/libs/"*

	# Install dist-info (METADATA, WHEEL, entry_points.txt,
	# top_level.txt) so importlib.metadata sees this package,
	# matching what pip would install -- minus RECORD, which lists the
	# paths/hashes pip's own installer would have produced and no
	# longer matches reality once this ebuild relocates semgrep-core/
	# libs and lets Gentoo's helpers place files under ${D}; nothing
	# here reads RECORD (Portage's own VDB is the uninstall mechanism).
	#
	# Copied to ${T}, not ${WORKDIR}: S=${WORKDIR} above, so a
	# ${WORKDIR}-based scratch path would collide with the source
	# dist-info dir itself, and rm -rf-ing it for idempotency would
	# delete the source out from under the following cp (this exact
	# failure mode was hit and fixed during testing).
	local distinfo="${T}/semgrep-${PV}.dist-info"
	rm -rf "${distinfo}" || die
	cp -r --no-target-directory "${S}/semgrep-${PV}.dist-info" "${distinfo}" || die
	rm "${distinfo}/RECORD" || die

	insinto "${sitedir#"${EPREFIX}"}"
	doins -r "${distinfo}"

	cat > "${T}/semgrep" <<-EOF || die
		#!/usr/bin/env python
		import sys
		from semgrep.console_scripts.entrypoint import main
		if __name__ == "__main__":
		    sys.exit(main())
	EOF
	cat > "${T}/pysemgrep" <<-EOF || die
		#!/usr/bin/env python
		import sys
		from semgrep.console_scripts.pysemgrep import main
		if __name__ == "__main__":
		    sys.exit(main())
	EOF
	python_newscript "${T}/semgrep" semgrep
	python_newscript "${T}/pysemgrep" pysemgrep

	dodoc "${DISTDIR}/${P}-"{semgrep-LICENSE,parsy-LICENSE,packaging-LICENSE}
	dodoc "${DISTDIR}/${P}-"{packaging-LICENSE.APACHE,packaging-LICENSE.BSD}
	dodoc "${DISTDIR}/${P}-"{interfaces-LICENSE,interfaces-NOTICE}
	dodoc "${DISTDIR}/tree-sitter-0.26.3-LICENSE"
	dodoc -r "${WORKDIR}/notices"
	dodoc "${FILESDIR}/semgrep-${PV}-license-audit.md"
	dodoc "${FILESDIR}/semgrep-${PV}-notice-index.json"
}
