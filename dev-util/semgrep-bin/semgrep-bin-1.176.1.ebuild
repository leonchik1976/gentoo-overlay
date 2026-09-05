# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python-single-r1.eclass does not (yet) support EAPI 9; keep this at 8
# until it does. python3_12/3_13/3_14 are all officially supported by
# the upstream wheel itself -- its own filename/WHEEL tags list
# cp312/cp313/cp314 (alongside cp310/cp311, dropped here as historical
# in this tree's python-utils-r1.eclass) -- and the ebuild's own
# install logic (unpack the wheel, patch RUNPATH, place files via
# python_domodule/python_newscript) has no Python-version-conditional
# code path, so it behaves identically under any of the three. python3.12
# was build/test-validated first; python3.14 has since been build/image
# -validated the same way (see the packaging report) with identical
# results, confirming this. Do not add python3_15 just because pkgcheck
# suggests it -- nothing in this dependency graph has been tested
# against it.
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit python-single-r1

DESCRIPTION="Lightweight static analysis, packaged from the official prebuilt PyPI wheel"
HOMEPAGE="
	https://semgrep.dev/
	https://github.com/semgrep/semgrep/
	https://pypi.org/project/semgrep/
"

# Immutable, hash-pinned files.pythonhosted.org URLs taken directly from
# https://pypi.org/pypi/semgrep/1.176.1/json (verified against the
# sha256 digests published there; see RDEPEND/comments below for the
# rest of the provenance trail). Do NOT point this at ::nest, ::pentoo,
# or any GitHub Actions build artifact.
SRC_URI="
	amd64? (
		https://files.pythonhosted.org/packages/17/97/ee08082667af4c3f0da56ad2af4f1e4cbd0b375200235c4ea6e1095b6742/semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_x86_64.whl
	)
	arm64? (
		https://files.pythonhosted.org/packages/8e/c9/c1a89c9bb7489199bca3cf3f4c8339c09fd28e4c58a81eed9cbb1c5edaba/semgrep-${PV}-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_aarch64.whl
	)
"
S="${WORKDIR}"

# --- LICENSE audit -----------------------------------------------------
# 1) Semgrep's own license (Python CLI + semgrep-core): LGPL-2.1-or-later,
#    per the wheel METADATA ("License-Expression: LGPL-2.1-or-later") and
#    the bundled LICENSE file text -> LGPL-2.1+.
#
# 2) ~25 third-party shared libraries are bundled under semgrep/bin/libs/.
#    Every one except libtree-sitter carries an embedded RPM debuginfo
#    build-id string (e.g. "libcrypto.so.3.5.5-3.5.5-6.el9_8.x86_64.debug").
#    That is provenance EVIDENCE, not proof: it establishes which
#    upstream project/version each .so was originally built from, but
#    does not by itself prove the copy bundled in the wheel is
#    byte-for-byte identical to that distro build. Licenses below are
#    inferred from the matching Gentoo package of the identified
#    project/version:
#      libbz2.so.1                    bzip2 1.0.8      -> BZIP2
#      libcrypto/libssl.so.3          openssl 3.5.5    -> Apache-2.0
#      libcurl.so.4                   curl 7.76.1      -> BSD curl
#      libdw/libelf.so.1              elfutils 0.194   -> || ( GPL-2+ LGPL-3+ )
#      libev.so.4                     libev 4.33       -> || ( BSD GPL-2 )
#      libgcc_s/libstdc++.so          gcc 11.5.0 rtlibs -> || ( libgcc libstdc++ gcc-runtime-library-exception-3.1 )
#      libgmp.so.10                   gmp 6.2.0        -> || ( LGPL-3+ GPL-2+ )
#      libgssapi_krb5/libk5crypto/
#        libkrb5/libkrb5support.so    mit-krb5 1.21.1  -> MIT (*)
#      libkeyutils.so.1               keyutils 1.6.3   -> LGPL-2.1 (*)
#      liblzma.so.5                   xz-utils 5.2.5   -> public-domain
#      libm/libresolv.so              glibc 2.34       -> LGPL-2.1+
#      libnghttp2.so.14                nghttp2 1.43.0   -> MIT
#      libpcre2-8.so.0                 pcre2 10.40      -> BSD
#      libselinux.so.1                 libselinux 3.6   -> public-domain
#      libunwind.so.8                  libunwind 1.8.0  -> MIT
#      libz.so.1                       zlib 1.2.11      -> ZLIB
#      libzstd.so.1                    zstd 1.5.5       -> || ( BSD GPL-2 )
#      libcom_err.so.2                 e2fsprogs 1.46.5 -> BSD (*)
#    (*) lower confidence: Gentoo's ebuild for the matching source
#        package lists a compound LICENSE= for its whole source tree,
#        not a per-file breakdown, so this one compiled library's exact
#        license was not confirmed at the source-file level. The MIT
#        entries above (krb5, nghttp2, libunwind) are unrelated to
#        tree-sitter below and do not extend to it.
#
# 3) UNRESOLVED (but with substantially stronger evidence than before):
#    libtree-sitter.so.0.22 has no distro debuginfo link, unlike every
#    other bundled library, and semgrep-core's stale RUNPATH
#    ("/src/semgrep-pro/OSS/libs/ocaml-tree-sitter-core/tree-sitter/
#    lib") points at Semgrep Inc.'s own private monorepo, not a distro
#    or stock upstream tree-sitter build.
#
#    Neither the wheel nor the sdist carries a NOTICE/SBOM, and PyPI
#    reports no provenance/attestation for either artifact (checked via
#    the PyPI JSON API's "provenance" field) -- there is no first-party
#    attestation trail to lean on.
#
#    That said, the public github.com/semgrep/ocaml-tree-sitter-core
#    repo (referenced by the stale RUNPATH's directory name) pins an
#    exact upstream tree-sitter release via its own tree-sitter-version
#    file ("0.22.6", matching our SONAME's 0.22 exactly) and carries
#    exactly one patch against it (patch/tree-sitter-0.22.6/0001-
#    Makefile-backports.patch) which touches ONLY the build Makefile
#    (cross-compile/platform-detection portability, not source logic,
#    not LICENSE/COPYING/NOTICE, not copyright headers). Upstream
#    tree-sitter's own LICENSE (github.com/tree-sitter/tree-sitter) is
#    plain MIT (Copyright (c) 2018-2024 Max Brunsfeld).
#
#    Static inspection of the bundled .so itself corroborates this:
#    its .comment section reads "GCC: (GNU) 11.5.0 20240719 (Red Hat
#    11.5.0-14)" -- the exact same AlmaLinux 9 toolchain string as
#    every other (distro-confirmed) bundled library, not a different
#    build environment -- and its embedded source-file strings
#    (lib/src/parser.c, lib/src/query.c, lib/src/subtree.c, ...) match
#    upstream tree-sitter's own repository layout. Its 137 exported
#    ts_* dynamic symbols (ts_parser_*, ts_node_*, ts_language_*, ts_
#    tree_*, ts_query_*, ts_lookahead_iterator_*, ...) match upstream
#    tree-sitter's public C API shape, not a renamed/restructured API.
#
#    None of this is a substitute for a direct statement from Semgrep
#    Inc. (NOTICE, SBOM, or equivalent), and it does NOT by itself
#    prove the private build has no additional undisclosed patches
#    beyond the one public one -- upstream tree-sitter's MIT license is
#    therefore still deliberately left out of LICENSE= below, and this
#    remains open work, not something the MIT entries elsewhere in this
#    list settle by association.
LICENSE="
	LGPL-2.1+
	BZIP2
	Apache-2.0
	BSD
	curl
	|| ( GPL-2+ LGPL-3+ )
	|| ( BSD GPL-2 )
	|| ( libgcc libstdc++ gcc-runtime-library-exception-3.1 )
	|| ( LGPL-3+ GPL-2+ )
	MIT
	LGPL-2.1
	public-domain
	ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Verified empirically (see the packaging report): running Portage's
# default `strip --strip-unneeded` against the pristine semgrep-core
# executable corrupts its dynamic symbol-versioning information and
# makes it fail with "no version information available" / a blank
# "symbol lookup error" for every dynamic dependency, even though the
# unstripped (or patchelf-only-modified) binary runs fine. QA_PREBUILT
# below only suppresses QA *warnings* for these files, it does not
# stop Portage from stripping them, so RESTRICT=strip is required too.
RESTRICT="mirror strip"

# This ebuild installs the complete official wheel (Python CLI +
# semgrep-core + bundled libs) as one package; it must not coexist
# with a source-built dev-util/semgrep or a standalone
# dev-util/semgrep-core, both of which would collide on
# /usr/bin/semgrep and the "semgrep"/"semdep" module trees. Both exist
# in the enabled ::nest repository, so this blocker is live and
# intentional even though pkgcheck reports NonexistentBlocker when
# scanning ::gentoo-overlay in isolation (it has no visibility into
# ::nest); do not remove it merely to silence that warning.
#
# --- dependency-version audit ------------------------------------------
# Every atom below is translated from the exact 1.176.1 wheel's Requires-Dist
# metadata, preserving
# upstream's PEP 440 compatible-release (~=) upper bounds as Gentoo
# range atoms instead of collapsing them to unbounded >=. ::gentoo's
# own versions of several of these packages fall outside the range
# upstream actually declares as compatible:
#   - exceptiongroup~=1.2.0 (>=1.2.0,<1.3): ::gentoo only has 1.3.1
#   - jsonschema~=4.25.1 (>=4.25.1,<4.26): ::gentoo has 4.24.0/4.26.0,
#     neither in range
#   - boltons~=21.0, peewee~=3.14 (<4), wcmatch~=8.3 (<9): ::gentoo
#     only has much newer out-of-range versions
# Using those newer ::gentoo versions instead would silently violate
# upstream's declared compatibility window with unverified behavior,
# so this overlay supplies its own compatibility-pinned versions
# instead: dev-python/boltons-21.0.0-r1, dev-python/exceptiongroup-1.2.2,
# dev-python/glom-25.12.0 (+ dev-python/face-26.0.1, a transitive
# dependency also missing from ::gentoo), dev-python/jsonschema-4.25.1,
# dev-python/mcp-1.29.0, dev-python/peewee-3.19.0, and
# dev-python/wcmatch-8.5.2. dev-python/opentelemetry-instrumentation-
# requests is likewise a new local package, but for a different reason
# -- see the OpenTelemetry exception below -- backed by a new
# dev-python/opentelemetry-util-http plus reuse of ::gentoo's
# opentelemetry-semantic-conventions-1.44.0 and ::guru's
# opentelemetry-instrumentation-0.65_beta0 (see metadata.xml for the
# full list of ::guru-sourced packages this ebuild's dependency graph
# relies on).
#
# --- intentional OpenTelemetry exception --------------------------------
# opentelemetry-api, opentelemetry-sdk, opentelemetry-exporter-otlp-
# proto-http, and opentelemetry-instrumentation-threading are pinned
# to the exact 1.44.0/0.65b0 versions instead of upstream's declared
# ~=1.37.0/~=0.58b0 windows. ::gentoo only carries opentelemetry-api/
# opentelemetry-sdk at 1.44.0 (nothing in the 1.37.x range exists
# there), and ::guru's opentelemetry-exporter-otlp-proto-http-1.44.0
# and opentelemetry-instrumentation-threading-0.65_beta0 are
# themselves exact-pinned (via their own ~= RDEPEND) to that same
# 1.44.0/0.65b0 release train. Pinning all four to 1.44.0/0.65b0
# keeps the whole OTel dependency graph internally consistent. This deliberate
# downstream compatibility relaxation was runtime-tested with Semgrep 1.176.1
# on arm64 and amd64: SemgrepState initialized and the requests/threading
# instrumentors completed instrument/uninstrument cycles against OTel
# 1.44.0/0.65b0. Upstream still declares the older 1.37/0.58 windows.
RDEPEND="
	${PYTHON_DEPS}
	!dev-util/semgrep
	!dev-util/semgrep-core
	$(python_gen_cond_dep '
		>=dev-python/attrs-21.3[${PYTHON_USEDEP}]
		>=dev-python/boltons-21.0[${PYTHON_USEDEP}]
		<dev-python/boltons-22[${PYTHON_USEDEP}]
		>=dev-python/click-option-group-0.5[${PYTHON_USEDEP}]
		<dev-python/click-option-group-1[${PYTHON_USEDEP}]
		>=dev-python/click-8.4.2[${PYTHON_USEDEP}]
		<dev-python/click-8.5[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.0[${PYTHON_USEDEP}]
		<dev-python/colorama-0.5[${PYTHON_USEDEP}]
		>=dev-python/exceptiongroup-1.2.0[${PYTHON_USEDEP}]
		<dev-python/exceptiongroup-1.3[${PYTHON_USEDEP}]
		>=dev-python/glom-23.3[${PYTHON_USEDEP}]
		>=dev-python/jsonschema-4.25.1[${PYTHON_USEDEP}]
		<dev-python/jsonschema-4.26[${PYTHON_USEDEP}]
		~dev-python/mcp-1.29.0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-api-1.44.0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-sdk-1.44.0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-exporter-otlp-proto-http-1.44.0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-instrumentation-requests-0.65_beta0[${PYTHON_USEDEP}]
		~dev-python/opentelemetry-instrumentation-threading-0.65_beta0[${PYTHON_USEDEP}]
		>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
		>=dev-python/peewee-3.14[${PYTHON_USEDEP}]
		<dev-python/peewee-4[${PYTHON_USEDEP}]
		>=dev-python/pyjwt-2.13.0[${PYTHON_USEDEP}]
		<dev-python/pyjwt-2.14[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		>=dev-python/requests-2.22[${PYTHON_USEDEP}]
		<dev-python/requests-3[${PYTHON_USEDEP}]
		>=dev-python/rich-13.5.2[${PYTHON_USEDEP}]
		>=dev-python/ruamel-yaml-0.18.15[${PYTHON_USEDEP}]
		~dev-python/ruamel-yaml-clib-0.2.15[${PYTHON_USEDEP}]
		>=dev-python/semantic-version-2.10.0[${PYTHON_USEDEP}]
		<dev-python/semantic-version-2.11[${PYTHON_USEDEP}]
		>=dev-python/tomli-2.4.0[${PYTHON_USEDEP}]
		<dev-python/tomli-2.5[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.2[${PYTHON_USEDEP}]
		<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
		>=dev-python/urllib3-2.0[${PYTHON_USEDEP}]
		<dev-python/urllib3-3[${PYTHON_USEDEP}]
		>=dev-python/wcmatch-8.3[${PYTHON_USEDEP}]
		<dev-python/wcmatch-9[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	app-arch/unzip
	dev-util/patchelf
"

# The wheel bundles a prebuilt native semgrep-core executable and its
# own vendored .so libraries (semgrep/bin/libs/*); they are
# intentionally left as-is (see LICENSE audit above) other than
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
	# ${A} contains exactly one file: the arch-conditional wheel
	# selected via SRC_URI above (amd64 and arm64 profile USE flags
	# are mutually exclusive). It is a zip archive, but named .whl,
	# so Portage's automatic unpack() (which dispatches on the
	# recognised suffix list) will not touch it -- unzip explicitly.
	unzip -q "${DISTDIR}/${A}" -d "${S}" || die
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

	# Install dist-info (METADATA, WHEEL, entry_points.txt, license
	# files, top_level.txt) so importlib.metadata sees this package,
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
}
