# Semgrep 1.180.0 bundled-license audit: INCOMPLETE

This package restores verified copyright/license documents from fetched,
Manifest-tracked upstream archives and distribution RPMs. Documentation
restoration does not establish complete binary provenance or satisfaction of
all source/relinking obligations. Upstream clarification is still outstanding.
A release-specific inquiry is drafted locally; no GitHub issue was created.

## Scope of the installed documents

The adjacent semgrep-1.180.0-notice-index.json records each original artifact
URL, archive member and installed document path. All selected texts are copied
verbatim. RPMs supply documentation only: no RPM is installed and none of their
executables or libraries is extracted into the package image. The x86_64 RPM
notice files were compared with the matching aarch64 RPMs and are identical.

The notices/ directory contains:

* native/: exact packaged notices for bzip2, libcom_err, OpenSSL, curl,
  elfutils/libelf, libev, GCC runtime, GMP, Kerberos, keyutils, xz, glibc,
  nghttp2, libselinux, libunwind, zlib, zstd; PCRE2's exact release LICENCE
  and COPYING. The libgcc directory contains GCC's common runtime exception
  and license texts relevant to libgcc/libstdc++. This is not a separate
  complete inventory of libstdc++ source copyrights.
* ocaml/: exact-release notices for ANSITerminal, Bos, ca-certs,
  Calendar, Fmt, MenhirLib, ocplib-endian,
  uring/liburing, Uucp and Uutf. Public lockfile pins and executable module
  symbols support attribution; they do not attest the entire static closure.
* semgrep-source/: grammar and tree-sitter binding notices present in the
  exact public v1.180.0 source. Some parent-directory license scope remains
  ambiguous. Including these notices does not decide whether a particular
  grant covers the generated parser or every nested source file.
* source-notices/: exact keyutils/glibc source files whose headers contain
  additional notices/grants, plus Semgrep's Range.ml linking-exception
  reference. These files are documentation, not inputs to a source rebuild.
* source-metadata/: semgrep.opam, preserving the LGPL-2.1-only declaration.

Some license files describe a whole upstream/distribution package and cover
more code than its bundled library. Their presence is not an instruction to
apply every package-wide license to Semgrep. Specific source grants take
precedence over generic COPYING files or automated license labels.

## Unresolved upstream questions

1. Exact static-core inputs for both official wheels: source commit, forked
   OCaml/runtime revisions, transitive static native components, patches,
   generated parser inputs and release build scripts. The 238-package public
   architecture lockfiles include build-only tools; they are not a wheel SBOM.
2. Scope of libs/ocaml-tree-sitter-semgrep/lang/semgrep-grammars/LICENSE
   (GPLv3), versus nested grammar grants such as Clojure's CC0. Determine
   which grant covers Semgrep extensions and each generated parser. A GPL
   generator alone does not establish the license of its output.
3. The wheel's License-Expression: LGPL-2.1-or-later conflicts with
   semgrep.opam's LGPL-2.1-only. Some source headers specify version 2.1 and
   reference a linking exception absent from the root LICENSE. Retaining
   LGPL-2.1 and LGPL-2.1+ in package metadata does not reconcile these grants.
   No blanket exception or permission to upgrade a specific grant is assumed.
4. Exact corresponding-source and any necessary relinking materials for
   these binaries, and complete component/notice coverage.

Historical issue #4281 records an LGPL clarification for redistributed
Semgrep in 2022; #2957 concerns missing license files and exception references.
Neither is a source attestation or exact-grant clarification for 1.180.0.
The current inquiry is deferred at the overlay owner's request.

## Corresponding-source and relinking requirements

These requirements come from the actual component grants and license texts,
not from merely accepting Gentoo's LICENSE expression. The applicable route
must be established per component and per act of distribution/conveyance.
Private use is distinct from distributing a wheel or Gentoo binary package.

* LGPL 2/2.1 library binaries: section 4 requires the complete corresponding
  machine-readable library source, including modifications, or its specified
  equivalent-access mechanism. Source includes the material and build/
  installation scripts required by the license. Identifying a nearby release
  archive or installing copyright notices alone does not establish this.
* LGPL 2/2.1 combined executables: where section 6 applies without a relevant
  exception, preserve notice/license text and permission for modification and
  reverse engineering for debugging modifications. One of section 6's routes
  must be met. Section 6(a) requires the library source and the work using it
  as source and/or objects sufficient to modify the library and relink. A
  suitable shared-library mechanism under 6(b) must actually work with an
  interface-compatible modified library. Sections 6(c)-(e) have their own
  conditions; no written offer is made or assumed by this ebuild.
* LGPL 3 library binaries also carry the applicable GPL 3 section 6 source
  conveyance requirements, as incorporated by LGPL 3. For combined works,
  section 4 requires notices plus the GPL and LGPL texts. Without a
  applicable exception, 4(d)(0) requires Minimal Corresponding Source and
  Corresponding Application Code permitting recombination/relinking, using
  the applicable GPL 3 section 6 conveyance route; 4(d)(1) alternatively
  permits a suitable replaceable shared-library mechanism. Installation
  Information is required under 4(e) only when its stated conditions apply.
* Component-specific OCaml linking exceptions can waive specified combined-
  executable requirements for eligible publicly distributed library versions.
  They do not automatically cover modified/private variants, unrelated
  components, or Semgrep's main grant. Preserve the exact exception and all
  requirements it leaves in force; do not invent a package-wide exemption.
* GCC runtime exception 3.1 is conditional on its definitions, including
  Eligible Compilation Processes. It is not a blanket exception for arbitrary
  bundled GPL code or every other library linked into the core.
* If upstream confirms that GPL-covered grammar inputs/templates contribute
  covered code to a shipped parser, the applicable GPL distribution/source
  obligations must also be established. No inference about generator output
  substitutes for the missing scope clarification.

The wheel's static OCaml module symbols do not demonstrate that source-only
relinking is reproducible. Bundled shared libraries and repaired RUNPATH do
not demonstrate replacement with a modified library. This packaging work
neither produces verified complete corresponding source nor performs a
modified-library relinking/replacement test. Do not treat fetched notice
artifacts as a completed source offer or proof that binary redistribution
requirements have been fulfilled.

## Evidence and testing limits

ELF code, read-only data and build IDs match official RPMs for 25 libraries
per architecture; only linking-related sections differ. Whole-file hashes do
not match. The tree-sitter binary on each architecture lacks an independently
reproduced match. RPM signatures were not verified; recorded official URLs,
artifact hashes and Portage Manifest checks do not substitute for signatures.

Click 8.5.0 and OpenTelemetry 1.45.1/0.66b1 remain explicitly downstream
compatibility choices, not upstream-supported bounds. Notice restoration
changes neither these overrides nor the installed wheel metadata patches.

Prior targeted native tests covered Python 3.12-3.14 on amd64/server01 and
arm64/gentoo. Fresh notice-installation checks are recorded in the local
validation report. No full Semgrep suite, complete mocket-dependent suite,
Python 3.15, Pro/cloud workflow, hermetic full dependency rebuild, static-core
source rebuild or modified-library relinking test is claimed. Architecture
keywords alone are not testing evidence. Profile/blocker QA findings remain.

Audit closure requires upstream resolution of all four questions above,
complete notice attribution and an evidenced applicable source/relinking
route. Until then, status remains INCOMPLETE.

## Authoritative sources and historical discussion

https://devmanual.gentoo.org/general-concepts/licenses/index.html
https://www.gnu.org/licenses/old-licenses/lgpl-2.0.html
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
https://www.gnu.org/licenses/lgpl-3.0.html
https://www.gnu.org/licenses/gpl-3.0.html
https://www.gnu.org/licenses/gcc-exception-3.1.html
https://pypi.org/pypi/semgrep/1.180.0/json
https://github.com/semgrep/semgrep/blob/v1.180.0/semgrep.opam
https://github.com/semgrep/semgrep/issues/4281#issuecomment-1111546149
https://github.com/semgrep/semgrep/issues/2957

The exact component texts under notices/ are the primary evidence for their
individual grants. The distribution mechanism and scope must be assessed
against those texts, not against the historical issues alone.
