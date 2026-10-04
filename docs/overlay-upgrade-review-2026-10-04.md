# Overlay upgrade and cleanup review — 2026-10-04

Updated 64 eligible packages and added four Perl dependencies needed by RT 6. There are 36 unchanged-content ebuild copies, 28 recipes requiring edits, and four new support recipes. All changes are uncommitted. No branch, commit, push, merge, or live-system package installation was performed.

## Evidence and validation

VERIFIED: `67` amd64 non-merging ebuild phase sequences returned exit 0 on `server01`; nine native arm64 sequences returned exit 0 on `gentoo`. Tests stopped at `ebuild … clean unpack prepare configure compile install`; the install phase wrote only to a temporary Portage package image under `/tmp/codex`. No `emerge`, merge, or qmerge ran. For binary packages, this verifies package-image construction, not compilation of the upstream payload. Source recipes actually reached their compile phases.

Exact commands, return codes, and raw logs are recorded in:

- `/tmp/codex/overlay-upgrades-20261004/build-results.json`
- `/tmp/codex/overlay-upgrades-20261004/retry-build-results.json`
- `/tmp/codex/overlay-upgrades-20261004/openclaw-build-results.json`
- `/tmp/codex/overlay-upgrades-20261004/arm64-build-results.json`

VERIFIED static commands and literal results:

```text
bash -n: 68 ebuilds; failures: []
git diff --check: exit 0; output: ''
pkgdev manifest results: 69 packages; nonzero exits: []
pkgdev manifest app-misc/n8n: manifests are up to date
pkgcheck scoped final: exit 0; packages: 71
kubectl-convert final pkgcheck: exit 0; output: empty
Python syntax: 2 changed generators; failures: []
Retained local dependency constraints: 273 edges; violations: []
Final ebuild count: 287 expected: 287
Empty package files/directories removed: []
```

Artifact inspection included exact release archives/wheels, build metadata and licenses, Cargo.lock/crate manifests, Go module licensing, ELF NEEDED/GLIBC requirements, Java jars, Debian package metadata, both AppImage file trees, patch dry runs, and installed-file lists. `bash -n` and Manifest generation are static checks; they are not build tests. Full per-package evidence lives under the package workspace pattern given at the end of this report.

VERIFIED in the follow-up below: RT 6 completed its full phase sequence on both architectures with staged dependency images. The original amd64 attempt stopped at absent dependencies; its historical output is retained here:

```text
    DBIx::SearchBuilder >= 1.85 ............................ MISSING (have 1.82)
    DateTime::Set .......................................... MISSING
    Hash::Merge ............................................ MISSING
    Hash::Merge::Extra ..................................... MISSING
    Imager ................................................. MISSING
    Time::ParseDate >= 2026.0219 ........................... MISSING (have 2015.103)
SOME DEPENDENCIES WERE MISSING:
    DBIx::SearchBuilder >= 1.85 ............................ MISSING (have 1.82)
    DateTime::Set .......................................... MISSING
    Hash::Merge ............................................ MISSING
    Hash::Merge::Extra ..................................... MISSING
    Imager ................................................. MISSING
    Time::ParseDate >= 2026.0219 ........................... MISSING (have 2015.103)
 *   Missing dependencies.
 *           die "Missing dependencies.";
```

The four new Perl support packages completed native package-image tests on both hosts. The follow-up below supplies missing dependencies from temporary images and completes RT’s phase tests; arm64 repository keyword gaps remain.

NOT VERIFIED: runtime GUI behavior, services, database migration, cloud integrations, and optional USE combinations not exercised by the recorded phase tests. Fifty-nine of the 68 new ebuilds still need native arm64 phase validation; amd64 does not apply to the arm64-only Sublime Text ebuild. Keywords indicate declarations, not completed architecture testing.

## Scoped QA findings

VERIFIED: original-HEAD baseline and final scoped scans both returned exit 0. Literal final output is reproduced below. The baseline comparison is in `pkgcheck-new-findings.json`; most musl/x32 constraints, deprecated httpx, package naming, Python compatibility suggestions, and Keycloak’s backend REQUIRED_USE were already present. New support packages expose missing arm64 dependency keywords; RT 6 adds further dependencies to its existing arm64 keyword-gap finding. These findings remain unresolved. No unrelated package was altered to hide them.

```text
app-admin/infracost-bin
  RequiredUseDefaults: version 2.17.0: profile: 'default/linux/amd64/23.0/musl' (9 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.17.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (9 total)

app-admin/kiro-cli-bin
  RequiredUseDefaults: version 2.27.1: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.27.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

app-admin/pulumi-bin
  NonsolvableDepsInDev: version 3.267.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 3.267.0: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 3.267.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

app-admin/serverless-bin
  NonsolvableDepsInDev: version 4.43.0: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-18.17.0 ]
  NonsolvableDepsInDev: version 4.43.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-18.17.0[ssl] ]

app-text/koodo-reader-bin
  NonsolvableDepsInDev: version 2.4.5: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (9 total): solutions: [ >=sys-libs/glibc-2.34 ]
  NonsolvableDepsInDev: version 2.4.5: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (9 total): solutions: [ >=sys-libs/glibc-2.38 ]

app-editors/cursor
  NonsolvableDepsInDev: version 3.22.12: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]

dev-db/beekeeper-studio-bin
  RequiredUseDefaults: version 6.1.5: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 6.1.5: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-python/mypy-boto3-s3
  PythonCompatUpdate: version 1.43.106: PYTHON_COMPAT update available: python3_15

app-misc/chatgpt-bin
  NonsolvableDepsInDev: version 26.930.41038: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ >=sys-libs/glibc-2.30 ]

dev-python/mypy-boto3-apigateway
  PythonCompatUpdate: version 1.43.100: PYTHON_COMPAT update available: python3_15

dev-db/dbgate-bin
  NonsolvableDepsInDev: version 7.3.1: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]

dev-python/ua-parser-builtins
  PythonCompatUpdate: version 202610: PYTHON_COMPAT update available: python3_15

dev-util/aws-cdk
  NonsolvableDepsInDev: version 2.1144.0: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-18 ]
  NonsolvableDepsInDev: version 2.1144.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-18[ssl] ]

dev-python/jh2
  PythonCompatUpdate: version 5.0.15: PYTHON_COMPAT update available: python3_15

dev-util/github-copilot-cli-bin
  NonsolvableDepsInDev: version 1.0.91: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 1.0.91: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.0.91: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-util/github-copilot-bin
  RequiredUseDefaults: version 1.1.26: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.1.26: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-python/slack-sdk
  PythonCompatUpdate: version 3.45.0: PYTHON_COMPAT update available: python3_15

dev-python/qh3
  PythonCompatUpdate: version 2.0.4: PYTHON_COMPAT update available: python3_15

dev-util/mise-bin
  RequiredUseDefaults: version 2026.10.1: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

app-misc/openclaw-bin
  NonsolvableDepsInDev: version 2026.9.8: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.9.8: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ <net-libs/nodejs-25, >=net-libs/nodejs-24.16.0, >=net-libs/nodejs-26.1.0 ]
  RequiredUseDefaults: version 2026.9.8: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.9.8: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-util/cursor-agent
  NonsolvableDepsInDev: version 2026.10.01: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.10.01: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-22.1.0 ]

sys-auth/keycloak-bin
  RequiredUseDefaults: version 26.8.0: profile: 'default/linux/amd64/23.0' (159 total) failed REQUIRED_USE: exactly-one-of ( h2-file h2-mem mariadb mssql mysql postgres )

sci-ml/lm-studio-bin
  NonsolvableDepsInDev: version 0.4.25_p1: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 0.4.25_p1: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 0.4.25_p1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

net-im/claude-desktop-bin
  NonsolvableDepsInDev: version 2.9939.4: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ >=sys-libs/glibc-2.34 ]

sys-process/falco-bin
  RequiredUseDefaults: version 0.45.0: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 0.45.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-perl/Hash-Merge-Extra
  NonsolvableDepsInDev: version 0.60.0: nonsolvable depset(bdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInDev: version 0.60.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInStable: version 0.60.0: nonsolvable depset(bdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInStable: version 0.60.0: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Hash-Merge ]

dev-perl/DBIx-SearchBuilder
  NonsolvableDepsInDev: version 1.850.0: nonsolvable depset(bdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInDev: version 1.850.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInStable: version 1.850.0: nonsolvable depset(bdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInStable: version 1.850.0: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]

www-client/brave-bin
  NonsolvableDepsInDev: version 1.96.61: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 1.96.61: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.96.61: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

www-apps/open-webui-bin
  PythonCompatUpdate: version 0.11.4: PYTHON_COMPAT updates available: python3_13, python3_14, python3_15

app-editors/kiro
  RequiredUseDefaults: version 1.2.4: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.2.4: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

www-apps/rt
  NonsolvableDepsInDev: version 6.0.3: nonsolvable depset(depend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2 ]
  NonsolvableDepsInDev: version 6.0.3: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2, www-servers/spawn-fcgi ]
  NonsolvableDepsInStable: version 6.0.3: nonsolvable depset(depend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2 ]
  NonsolvableDepsInStable: version 6.0.3: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2, www-servers/spawn-fcgi ]

app-misc/n8n
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0[npm] ]
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(depend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0:0= ]
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0:0= ]
  RequiredUseDefaults: version 2.41.6: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.41.6: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-python/ollama-python
  PythonMismatchedPackageName: package name does not match remote-id, recommended name: 'ollama'
  DeprecatedDep: version 0.6.3: BDEPEND: deprecated dependency: dev-python/httpx[python_targets_python3_12(-)?,python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?]
  DeprecatedDep: version 0.6.3: RDEPEND: deprecated dependency: dev-python/httpx[python_targets_python3_12(-)?,python_targets_python3_13(-)?,python_targets_python3_14(-)?,python_targets_python3_15(-)?]

app-misc/n8n-task-runners
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0[npm] ]
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(depend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0:0= ]
  NonsolvableDepsInDev: version 2.41.6: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ >=net-libs/nodejs-24.0.0:0= ]
  RequiredUseDefaults: version 2.41.6: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.41.6: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

dev-util/semgrep-bin
  NonexistentBlocker: version 1.179.0: nonexistent blocker RDEPEND="!dev-util/semgrep": no matches in repo history
  NonexistentBlocker: version 1.179.0: nonexistent blocker RDEPEND="!dev-util/semgrep-core": no matches in repo history
```

## Version constraints and suitability

The dependency map was produced before eligibility decisions; the initial inventory and exact discovery/constraint sources are preserved in `/tmp/report.txt`. AWS SAM CLI and aws-cdk-local were checked first. Their selected existing versions remain unchanged. aws-cdk-local’s existing CDK range admits the new CDK version. New ollmcp releases require MCP 2; Semgrep requires MCP 1, so ollmcp and the incompatible dependency upgrades were excluded. Elastic’s five coordinated packages remain at the same existing version. The original upstream exclusions were honored. No upstream availability queries were made during cleanup.

For every package below, the release artifact/source was inspected before accepting the recipe. Copy = identical ebuild contents under a new versioned filename. Edits = a recipe change was required. Source links identify the exact selected release; expanded dependency metadata and full source URL lists are in `metadata-final.json`.

| Package | Old → new | Recipe | Exact release source | amd64 / server01 | arm64 / gentoo |
|---|---|---|---|---|---|
| `app-admin/aws-vault-bin` | 7.14.0 → 7.15.3 | Copy | [artifact](https://github.com/ByteNess/aws-vault/releases/download/v7.15.3/aws-vault-linux-amd64); [artifact](https://github.com/ByteNess/aws-vault/releases/download/v7.15.3/aws-vault-linux-arm64) | exit 0 | NOT VERIFIED |
| `app-admin/fluent-bit` | 5.1.2 → 5.1.3 | Edits | [artifact](https://github.com/fluent/fluent-bit/archive/refs/tags/v5.1.3.tar.gz) | exit 0 | NOT VERIFIED |
| `app-admin/infracost-bin` | 2.16.3 → 2.17.0 | Copy | [artifact](https://github.com/infracost/cli/releases/download/v2.17.0/infracost-linux-amd64.tar.gz); [artifact](https://github.com/infracost/cli/releases/download/v2.17.0/infracost-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `app-admin/istioctl-bin` | 1.31.0 → 1.31.1 | Copy | [artifact](https://github.com/istio/istio/releases/download/1.31.1/istioctl-1.31.1-linux-amd64.tar.gz); [artifact](https://github.com/istio/istio/releases/download/1.31.1/istioctl-1.31.1-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `app-admin/kiro-cli-bin` | 2.22.0 → 2.27.1 | Copy | [artifact](https://prod.download.cli.kiro.dev/stable/2.27.1/kirocli-x86_64-linux.tar.gz); [artifact](https://prod.download.cli.kiro.dev/stable/2.27.1/kirocli-aarch64-linux.tar.gz) | exit 0 | NOT VERIFIED |
| `app-admin/pulumi-bin` | 3.263.0 → 3.267.0 | Edits | [artifact](https://github.com/pulumi/pulumi/releases/download/v3.267.0/pulumi-v3.267.0-linux-x64.tar.gz); [artifact](https://github.com/pulumi/pulumi/releases/download/v3.267.0/pulumi-v3.267.0-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `app-admin/serverless-bin` | 4.42.0 → 4.43.0 | Copy | [artifact](https://install.serverless.com/archives/serverless-4.43.0.tgz) | exit 0 | NOT VERIFIED |
| `app-admin/terragrunt-bin` | 1.1.5 → 1.1.6 | Edits | [artifact](https://github.com/gruntwork-io/terragrunt/releases/download/v1.1.6/terragrunt_linux_amd64); [artifact](https://github.com/gruntwork-io/terragrunt/releases/download/v1.1.6/terragrunt_linux_arm64) | exit 0 | NOT VERIFIED |
| `app-containers/localstack-cli-bin` | 2026.8.0 → 2026.8.2 | Copy | [artifact](https://github.com/localstack/localstack-cli/releases/download/v2026.8.2/localstack-cli-2026.8.2-linux-amd64.tar.gz); [artifact](https://github.com/localstack/localstack-cli/releases/download/v2026.8.2/localstack-cli-2026.8.2-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `app-containers/lstk-bin` | 1.1.0 → 1.3.0 | Copy | [artifact](https://github.com/localstack/lstk/releases/download/v1.3.0/lstk_1.3.0_linux_amd64.tar.gz); [artifact](https://github.com/localstack/lstk/releases/download/v1.3.0/lstk_1.3.0_linux_arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `app-editors/cursor` | 3.21.16 → 3.22.12 | Edits | [artifact](https://downloads.cursor.com/production/3a92974361033b2051526321308c2740fe5912c5/linux/x64/deb/amd64/deb/cursor_3.22.12_amd64.deb); [artifact](https://downloads.cursor.com/production/3a92974361033b2051526321308c2740fe5912c5/linux/arm64/deb/arm64/deb/cursor_3.22.12_arm64.deb) | exit 0 | NOT VERIFIED |
| `app-editors/kiro` | 1.1.14 → 1.2.4 | Copy | [artifact](https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.2.4/deb/kiro-ide-1.2.4-stable-linux-x64.deb); [artifact](https://prod.download.desktop.kiro.dev/releases/stable/linux-arm64/signed/1.2.4/deb/kiro-ide-1.2.4-stable-linux-arm64.deb) | exit 0 | NOT VERIFIED |
| `app-editors/sublime-text` | 4_p4200 → 4_p4215 | Edits | [artifact](https://download.sublimetext.com/sublime_text_build_4215_arm64.tar.xz) | not applicable | exit 0 |
| `app-misc/chatgpt-bin` | 26.915.31945 → 26.930.41038 | Copy | [artifact](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.930.41038_amd64.deb); [artifact](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.930.41038_arm64.deb) | exit 0 | NOT VERIFIED |
| `app-misc/grok-bot-bin` | 0.57.1 → 0.66.0 | Edits | [artifact](https://downloads.cursor.com/grokbot/stable/12fb477da4023dc110998df181ec150d29c355f2/linux/x64/grok-bot_0.66.0_amd64.deb); [artifact](https://downloads.cursor.com/grokbot/stable/12fb477da4023dc110998df181ec150d29c355f2/linux/arm64/grok-bot_0.66.0_arm64.deb) | exit 0 | NOT VERIFIED |
| `app-misc/openclaw-bin` | 2026.9.5 → 2026.9.8 | Edits | [artifact](https://registry.npmjs.org/openclaw/-/openclaw-2026.9.8.tgz) | exit 0 | exit 0 |
| `app-shells/oh-my-posh-bin` | 31.3.0 → 31.4.1 | Edits | [artifact](https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v31.4.1/posh-linux-amd64); [artifact](https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v31.4.1/posh-linux-arm64) | exit 0 | NOT VERIFIED |
| `app-text/koodo-reader-bin` | 2.4.4 → 2.4.5 | Edits | [artifact](https://github.com/koodo-reader/koodo-reader/releases/download/v2.4.5/Koodo-Reader-2.4.5-amd64.deb); [artifact](https://github.com/koodo-reader/koodo-reader/releases/download/v2.4.5/Koodo-Reader-2.4.5-arm64.deb) | exit 0 | exit 0 |
| `dev-db/beekeeper-studio-bin` | 6.1.2 → 6.1.5 | Copy | [artifact](https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v6.1.5/beekeeper-studio_6.1.5_amd64.deb); [artifact](https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v6.1.5/beekeeper-studio_6.1.5_arm64.deb) | exit 0 | NOT VERIFIED |
| `dev-db/clickhouse-bin` | 26.8.8.8 → 26.8.16.41 | Copy | [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-server-26.8.16.41-amd64.tgz); [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-server-26.8.16.41-arm64.tgz) | exit 0 | NOT VERIFIED |
| `dev-db/clickhouse-client-bin` | 26.8.8.8 → 26.8.16.41 | Copy | [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-client-26.8.16.41-amd64.tgz); [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-client-26.8.16.41-arm64.tgz) | exit 0 | NOT VERIFIED |
| `dev-db/clickhouse-common-static-bin` | 26.8.8.8 → 26.8.16.41 | Copy | [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-common-static-26.8.16.41-amd64.tgz); [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.8.16.41-lts/clickhouse-common-static-26.8.16.41-arm64.tgz) | exit 0 | NOT VERIFIED |
| `dev-db/dbgate-bin` | 7.3.0 → 7.3.1 | Copy | [artifact](https://github.com/dbgate/dbgate/releases/download/v7.3.1/dbgate-7.3.1-linux_x86_64.AppImage); [artifact](https://github.com/dbgate/dbgate/releases/download/v7.3.1/dbgate-7.3.1-linux_arm64.AppImage) | exit 0 | NOT VERIFIED |
| `dev-db/neo4j-bin` | 2026.08.1 → 2026.09.0 | Copy | [artifact](https://dist.neo4j.org/neo4j-community-2026.09.0-unix.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-db/opensearch-bin` | 3.8.0 → 3.9.0 | Copy | [artifact](https://artifacts.opensearch.org/releases/bundle/opensearch/3.9.0/opensearch-3.9.0-linux-x64.tar.gz); [artifact](https://artifacts.opensearch.org/releases/bundle/opensearch/3.9.0/opensearch-3.9.0-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-db/postgresql_anonymizer` | 3.2.2 → 3.2.3 | Copy | [artifact](https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/3.2.3/postgresql_anonymizer-3.2.3.tar.bz2) | exit 0 | NOT VERIFIED |
| `dev-java/groovy-bin` | 5.1.2 → 6.0.0 | Edits | [artifact](https://dlcdn.apache.org/groovy/6.0.0/distribution/apache-groovy-binary-6.0.0.zip); [artifact](https://archive.apache.org/dist/groovy/6.0.0/distribution/apache-groovy-binary-6.0.0.zip) | exit 0 | exit 0 |
| `dev-python/boto3-stubs` | 1.43.98 → 1.43.108 | Copy | [artifact](https://files.pythonhosted.org/packages/source/b/boto3-stubs/boto3_stubs-1.43.108.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/jellyfin-apiclient-python` | 1.18.0 → 1.19.0 | Copy | [artifact](https://files.pythonhosted.org/packages/source/j/jellyfin-apiclient-python/jellyfin_apiclient_python-1.19.0.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/jh2` | 5.0.14 → 5.0.15 | Edits | [artifact](https://files.pythonhosted.org/packages/source/j/jh2/jh2-5.0.15.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/mypy-boto3-apigateway` | 1.43.0 → 1.43.100 | Copy | [artifact](https://files.pythonhosted.org/packages/source/m/mypy-boto3-apigateway/mypy_boto3_apigateway-1.43.100.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/mypy-boto3-kinesis` | 1.43.86 → 1.43.101 | Copy | [artifact](https://files.pythonhosted.org/packages/source/m/mypy-boto3-kinesis/mypy_boto3_kinesis-1.43.101.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/mypy-boto3-s3` | 1.43.93 → 1.43.106 | Copy | [artifact](https://files.pythonhosted.org/packages/source/m/mypy-boto3-s3/mypy_boto3_s3-1.43.106.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/niquests` | 3.21.1 → 3.21.2 | Copy | [artifact](https://files.pythonhosted.org/packages/source/n/niquests/niquests-3.21.2.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/ollama-python` | 0.6.2 → 0.6.3 | Edits | [artifact](https://github.com/ollama/ollama-python/archive/refs/tags/v0.6.3.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/pipx` | 1.17.4 → 1.17.11 | Edits | [artifact](https://github.com/pypa/pipx/archive/1.17.11.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/qh3` | 2.0.3 → 2.0.4 | Edits | [artifact](https://files.pythonhosted.org/packages/source/q/qh3/qh3-2.0.4.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/slack-sdk` | 3.44.1 → 3.45.0 | Copy | [artifact](https://files.pythonhosted.org/packages/source/s/slack-sdk/slack_sdk-3.45.0.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-python/ua-parser-builtins` | 202606 → 202610 | Edits | [artifact](https://files.pythonhosted.org/packages/py3/u/ua-parser-builtins/ua_parser_builtins-202610-py3-none-any.whl) | exit 0 | NOT VERIFIED |
| `dev-python/urllib3-future` | 2.24.908 → 2.25.901 | Copy | [artifact](https://files.pythonhosted.org/packages/source/u/urllib3-future/urllib3_future-2.25.901.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-util/aws-cdk` | 2.1142.0 → 2.1144.0 | Copy | [artifact](https://registry.npmjs.org/aws-cdk/-/aws-cdk-2.1144.0.tgz) | exit 0 | NOT VERIFIED |
| `dev-util/cursor-agent` | 2026.09.18 → 2026.10.01 | Edits | [artifact](https://downloads.cursor.com/lab/2026.10.01-e373342/linux/x64/agent-cli-package.tar.gz); [artifact](https://downloads.cursor.com/lab/2026.10.01-e373342/linux/arm64/agent-cli-package.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-util/github-copilot-bin` | 1.1.22 → 1.1.26 | Edits | [artifact](https://github.com/github/app/releases/download/v1.1.26/GitHub-Copilot-linux-x64.deb); [artifact](https://github.com/github/app/releases/download/v1.1.26/GitHub-Copilot-linux-arm64.deb) | exit 0 | NOT VERIFIED |
| `dev-util/github-copilot-cli-bin` | 1.0.86 → 1.0.91 | Copy | [artifact](https://github.com/github/copilot-cli/releases/download/v1.0.91/copilot-linux-x64.tar.gz); [artifact](https://github.com/github/copilot-cli/releases/download/v1.0.91/copilot-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-util/mise-bin` | 2026.9.11 → 2026.10.1 | Copy | [artifact](https://github.com/jdx/mise/releases/download/v2026.10.1/mise-v2026.10.1-linux-x64.tar.gz); [artifact](https://github.com/jdx/mise/releases/download/v2026.10.1/mise-v2026.10.1-linux-arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `dev-util/postman-bin` | 12.28.6 → 12.30.6 | Copy | [artifact](https://dl.pstmn.io/download/version/12.30.6/linux64); [artifact](https://dl.pstmn.io/download/version/12.30.6/linux_arm64) | exit 0 | NOT VERIFIED |
| `dev-util/semgrep-bin` | 1.177.0 → 1.179.0 | Edits | [artifact](https://files.pythonhosted.org/packages/cc/6c/621944b4843c7484aeaefd5b232d93780bdf95259567c10a9a8129f08dc6/semgrep-1.179.0-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_x86_64.whl); [artifact](https://files.pythonhosted.org/packages/e3/ba/b9f1afbed852a21b6f7e72c064343161c5ab249954c46db1796b59314290/semgrep-1.179.0-cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314-none-manylinux_2_34_aarch64.whl) | exit 0 | NOT VERIFIED |
| `dev-util/trivy` | 0.74.0 → 0.75.0 | Edits | [artifact](https://github.com/aquasecurity/trivy/releases/download/v0.75.0/trivy_0.75.0_Linux-64bit.tar.gz); [artifact](https://github.com/aquasecurity/trivy/releases/download/v0.75.0/trivy_0.75.0_Linux-ARM64.tar.gz) | exit 0 | NOT VERIFIED |
| `net-im/claude-desktop-bin` | 2.2553.1 → 2.9939.4 | Copy | [artifact](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_2.9939.4_amd64.deb); [artifact](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_2.9939.4_arm64.deb) | exit 0 | NOT VERIFIED |
| `sci-ml/lm-studio-bin` | 0.4.24_p1 → 0.4.25_p1 | Edits | [artifact](https://installers.lmstudio.ai/linux/x64/0.4.25-1/LM-Studio-0.4.25-1-x64.AppImage); [artifact](https://installers.lmstudio.ai/linux/arm64/0.4.25-1/LM-Studio-0.4.25-1-arm64.AppImage) | exit 0 | NOT VERIFIED |
| `sys-auth/keycloak-bin` | 26.7.4 → 26.8.0 | Edits | [artifact](https://github.com/keycloak/keycloak/releases/download/26.8.0/keycloak-26.8.0.tar.gz) | exit 0 | NOT VERIFIED |
| `sys-cluster/bom-bin` | 0.7.1 → 0.8.0 | Edits | [artifact](https://github.com/kubernetes-sigs/bom/releases/download/v0.8.0/bom-amd64-linux); [artifact](https://github.com/kubernetes-sigs/bom/releases/download/v0.8.0/bom-arm64-linux) | exit 0 | NOT VERIFIED |
| `sys-cluster/egctl-bin` | 1.9.1 → 1.9.2 | Copy | [artifact](https://github.com/envoyproxy/gateway/releases/download/v1.9.2/egctl_v1.9.2_linux_amd64.tar.gz); [artifact](https://github.com/envoyproxy/gateway/releases/download/v1.9.2/egctl_v1.9.2_linux_arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `sys-cluster/k3s-bin` | 1.37.0_p1 → 1.37.1_p1 | Edits | [artifact](https://github.com/k3s-io/k3s/releases/download/v1.37.1+k3s1/k3s); [artifact](https://github.com/k3s-io/k3s/releases/download/v1.37.1+k3s1/k3s-arm64) | exit 0 | NOT VERIFIED |
| `sys-cluster/kubectl-convert` | 1.37.0 → 1.37.1 | Edits | [artifact](https://github.com/kubernetes/kubernetes/archive/v1.37.1.tar.gz) | exit 0 | NOT VERIFIED |
| `sys-cluster/kubescape-bin` | 4.0.14 → 4.0.15 | Copy | [artifact](https://github.com/kubescape/kubescape/releases/download/v4.0.15/kubescape_4.0.15_linux_amd64.tar.gz); [artifact](https://github.com/kubescape/kubescape/releases/download/v4.0.15/kubescape_4.0.15_linux_arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `sys-cluster/kustomize-bin` | 5.8.1 → 5.8.2 | Copy | [artifact](https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.8.2/kustomize_v5.8.2_linux_amd64.tar.gz); [artifact](https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.8.2/kustomize_v5.8.2_linux_arm64.tar.gz) | exit 0 | NOT VERIFIED |
| `sys-process/falco-bin` | 0.44.1 → 0.45.0 | Edits | [artifact](https://download.falco.org/packages/bin/x86_64/falco-0.45.0-x86_64.tar.gz); [artifact](https://download.falco.org/packages/bin/aarch64/falco-0.45.0-aarch64.tar.gz) | exit 0 | NOT VERIFIED |
| `www-apps/draw-io` | 31.4.6 → 32.0.2 | Edits | [artifact](https://github.com/jgraph/drawio/archive/refs/tags/v32.0.2.tar.gz) | exit 0 | NOT VERIFIED |
| `www-apps/open-webui-bin` | 0.11.3 → 0.11.4 | Edits | [artifact](https://files.pythonhosted.org/packages/ca/8d/051d8145b88cb3f97f9e165feaa4a266aa46f4f5f2df67affb0e72ba8066/open_webui-0.11.4-py3-none-any.whl) | exit 0 | NOT VERIFIED |
| `www-apps/owncloud` | 11.0.0 → 11.0.1 | Copy | [artifact](https://github.com/owncloud/core/releases/download/v11.0.1/owncloud-11.0.1.tar.bz2) | exit 0 | NOT VERIFIED |
| `www-apps/rt` | 5.0.10-r1 → 6.0.3 | Edits | [artifact](https://download.bestpractical.com/pub/rt/release/rt-6.0.3.tar.gz) | exit 0 (staged Perl) | exit 0 (staged Perl) |
| `www-apps/selenium-server-bin` | 4.49.0 → 4.50.0 | Copy | [artifact](https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.50.0/selenium-server-4.50.0.jar) | exit 0 | NOT VERIFIED |
| `www-client/brave-bin` | 1.95.104 → 1.96.61 | Copy | [artifact](https://github.com/brave/brave-browser/releases/download/v1.96.61/brave-browser_1.96.61_amd64.deb); [artifact](https://github.com/brave/brave-browser/releases/download/v1.96.61/brave-browser_1.96.61_arm64.deb) | exit 0 | NOT VERIFIED |
| `dev-perl/Imager` | new package → 1.37.0 | New support | [artifact](mirror://cpan/authors/id/T/TO/TONYC/Imager-1.037.tar.gz) | exit 0 | exit 0 |
| `dev-perl/Hash-Merge-Extra` | new package → 0.60.0 | New support | [artifact](mirror://cpan/authors/id/M/MI/MIXAS/Hash-Merge-Extra-0.06.tar.gz) | exit 0 | exit 0 |
| `dev-perl/DBIx-SearchBuilder` | new package → 1.850.0 | New support | [artifact](mirror://cpan/authors/id/B/BP/BPS/DBIx-SearchBuilder-1.85.tar.gz) | exit 0 | exit 0 |
| `dev-perl/Time-ParseDate` | new package → 2026.33.0 | New support | [artifact](mirror://cpan/authors/id/B/BP/BPS/Time-ParseDate-2026.033.tar.gz) | exit 0 | exit 0 |

## Recipe changes and rationale

- Fluent Bit: retain build/USE behavior; append inherited BDEPEND and include the BSD/MIT/public-domain licenses of bundled libraries actually compiled. Exact evidence: `lib/snappy-fef67ac/LICENSE`, `lib/cfl/lib/xxhash/LICENSE`, `lib/onigmo/COPYING`, `lib/mpack-amalgamation-1.1.1/LICENSE`, `lib/tutf8e/LICENSE`, and Monkey libco headers in the v5.1.3 source archive linked above.
- Cursor, Cursor Agent, Grok Bot, and LM Studio: replace immutable release/build identifiers and upstream filename translations; recipe layout remains compatible with inspected artifacts.
- Sublime Text: keep arm64-only keywords; install the new Python 3.14 plugin host, new shared libraries, and attribution file. Native arm64 package-image test completed.
- OpenClaw: regenerate the exact new runtime npm lock/dependency closure and license inventory; retain upstream bundled packages and permit existing node_modules with mkdir -p. Extend the generator’s native Linux variant handling and reject conflicting license records.
- Oh My Posh: refresh exact Go module versions and the versioned dependency notice. New recipe completed its retry.
- Koodo Reader: amd64 no longer ships chrome-sandbox; apply the sandbox ownership/check logic only to arm64, which still ships it. Both native package-image tests completed.
- Groovy: raise the Java minimum to 17 for Groovy 6 and audit bundled jar licenses; add the exact Indiana University Extreme! license text. [Official release notes](https://groovy-lang.org/releasenotes/groovy-6.0.html).
- Pipx: update runtime/build dependency floors from the exact new pyproject and PyPI metadata. Preserve the existing meaningful uv USE choice; do not turn optional imports into new convenience USE flags.
- Jh2 and Qh3: regenerate exact Cargo.lock crate lists and audit MSRV/licensing; Qh3 includes the legacy OpenSSL license shipped in aws-lc-sys. Both real amd64 compilation retries completed.
- PostgreSQL Anonymizer: the lockfile and pgrx 0.19.1 requirements remain suitable; keep the existing PostgreSQL 14–18 targets because only a PostgreSQL 19 beta is in the available Gentoo tree. Real compilation against PostgreSQL 18 completed.
- Semgrep: replace immutable CPython/platform wheel URLs and update the PyJWT floor from exact wheel metadata. Preserve existing documented dependency relaxations and expose their uncertainty rather than claiming upstream compatibility.
- Falco: update the exact driver/lib commit pins and source license notices; preserve the verified conditional license expression.
- Draw.io: upstream removed Xml2Js.java and stencil XML sources; remove that obsolete compilation step and retain upstream’s bundled stencils.min.js, matching its Ant build. The Java release-8 patch still applies. Retry completed.
- Open WebUI: regenerate the private wheel closure for both architectures, preserve audited provider-collision overrides and CPU PyTorch pin, validate dependency metadata in the temporary image, and extend the license expression from shipped dependency license texts. The generator restricts sources to PyPI and exact official CPU PyTorch overrides.
- RT 6: update dependencies and bounds from the exact cpanfile/Makefile source and remove the obsolete configure option. Add Imager, Hash::Merge::Extra, DBIx::SearchBuilder, and Time::ParseDate recipes after verifying their CPAN sources. Time::Piece is part of core Perl, so no nonexistent virtual dependency remains.
- kubectl-convert: preserve the existing same-minor kubectl client range instead of mechanically requiring the identical patch version. INFERRED from [upstream standalone plugin behavior](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/) and the exact source; runtime invocation with kubectl 1.37.0 is NOT VERIFIED. Audit the actual Go dependency closure and exclude documentation-only CC-BY-SA and the false imagemagick identification.
- Pulumi, Terragrunt, Trivy, BOM and K3s: update license expressions from actual module license texts; exclude documentation-only licenses and classifier false positives. Terragrunt’s embedded font license is OFL-1.1.
- Other recipe edits preserve inherited BDEPEND values by appending, and correct generated metadata or source-specific details. No new USE flags were added. The table identifies every recipe that required edits; exact diffs are in `ebuild-changes-final.json`.

## License evidence and remaining uncertainty

Gentoo LICENSE identifiers follow the current `::gentoo/licenses` files; for example upstream SPDX CNRI-Python maps to Gentoo CNRI. The table records the resulting LICENSE value. Exact artifact URLs above, per-package `source-audit.json`, `artifact-audit.json`, `go-licenses-*.json`, crate audits, and private dependency license inventories contain the inspected source evidence. No license was inferred solely from another overlay.

NOT VERIFIED: an independent license grant for `github.com/infracost/go-proto@v1.30.0` could not be found in its exact module archive; both the tagged LICENSE URL and GitHub license endpoint returned HTTP 404. Infracost’s existing Apache-2.0 declaration is retained from its own upstream project license, but this missing module grant remains an upstream licensing uncertainty. AWS Vault’s stripped binary provides no usable Go module build information, so its full transitive binary license closure was not independently verified. Pulumi’s Appdash asset-parent grant was separately read at [the upstream parent LICENSE](https://raw.githubusercontent.com/sourcegraph/appdash/master/LICENSE), which is MIT.

| Package | LICENSE in new ebuild |
|---|---|
| `app-admin/aws-vault-bin` | `MIT Apache-2.0 BSD BSD-2` |
| `app-admin/fluent-bit` | `Apache-2.0 BSD BSD-2 MIT public-domain` |
| `app-admin/infracost-bin` | `Apache-2.0 BSD MIT MPL-2.0 Unicode-DFS-2016 Unlicense` |
| `app-admin/istioctl-bin` | `Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 ISC imagemagick MIT MPL-2.0` |
| `app-admin/kiro-cli-bin` | `all-rights-reserved` |
| `app-admin/pulumi-bin` | `Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense` |
| `app-admin/serverless-bin` | `Serverless-Customer-Agreement-20251201` |
| `app-admin/terragrunt-bin` | `Apache-2.0 BSD BSD-2 MIT MPL-2.0 OFL-1.1 Unicode-DFS-2016` |
| `app-containers/localstack-cli-bin` | `Apache-2.0 BSD BSD-2 BZIP2 GPL-3+ HPND LGPL-2.1+ MIT MPL-2.0 openssl PSF-2 ZLIB || ( Artistic GPL-1+ )` |
| `app-containers/lstk-bin` | `Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 MIT MPL-2.0 Unicode-DFS-2016` |
| `app-editors/cursor` | `all-rights-reserved` |
| `app-editors/kiro` | `all-rights-reserved` |
| `app-editors/sublime-text` | `Sublime` |
| `app-misc/chatgpt-bin` | `all-rights-reserved MIT` |
| `app-misc/grok-bot-bin` | `all-rights-reserved Apache-2.0 Apache-2.0-with-LLVM-exceptions APSL-2 Base64 Boost-1.0 BSD BSD-2 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 LGPL-2.1+ libpng libtiff MIT MPL-1.1 MPL-2.0 Ms-PL openssl PSF-2 public-domain SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB` |
| `app-misc/openclaw-bin` | `MIT Apache-2.0 Artistic-2 BSD BSD-2 BlueOak-1.0.0 CC-BY-3.0 CC0-1.0 ISC MPL-2.0 0BSD Unlicense ZLIB || ( MIT GPL-3+ ) || ( MIT Apache-2.0 )` |
| `app-shells/oh-my-posh-bin` | `MIT Apache-2.0 BSD BSD-2` |
| `app-text/koodo-reader-bin` | `AGPL-3 0BSD AFL-2.1 APSL-2 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 BSD-4 Boost-1.0 CC-BY-3.0 CC-BY-SA-3.0 FFT2D FTL GPL-2 IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL OFL-1.1 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB all-rights-reserved android libpng libtiff openssl public-domain unRAR` |
| `dev-db/beekeeper-studio-bin` | `GPL-3+ Beekeeper-Studio-EULA-20260702` |
| `dev-db/clickhouse-bin` | `Apache-2.0` |
| `dev-db/clickhouse-client-bin` | `Apache-2.0` |
| `dev-db/clickhouse-common-static-bin` | `Apache-2.0 BSD-2 BSD Boost-1.0 BZIP2 ISC MIT` |
| `dev-db/dbgate-bin` | `GPL-3 Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl` |
| `dev-db/neo4j-bin` | `Apache-2.0 BSD BSD-2 CDDL-1.1 EPL-1.0 EPL-2.0 GPL-2-with-classpath-exception GPL-3 MIT MPL-2.0` |
| `dev-db/opensearch-bin` | `Apache-2.0 BSD CC0-1.0 EPL-2.0 MIT` |
| `dev-db/postgresql_anonymizer` | `Apache-2.0 BSD BSD-2 ISC MIT POSTGRESQL UoI-NCSA Unicode-3.0 ZLIB` |
| `dev-java/groovy-bin` | `Apache-2.0 BSD BSD-2 EPL-1.0 EPL-2.0 Indiana-Extreme-1.2 MIT MIT-0 public-domain` |
| `dev-python/boto3-stubs` | `MIT` |
| `dev-python/jellyfin-apiclient-python` | `GPL-3` |
| `dev-python/jh2` | `MIT Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0` |
| `dev-python/mypy-boto3-apigateway` | `MIT` |
| `dev-python/mypy-boto3-kinesis` | `MIT` |
| `dev-python/mypy-boto3-s3` | `MIT` |
| `dev-python/niquests` | `Apache-2.0` |
| `dev-python/ollama-python` | `MIT` |
| `dev-python/pipx` | `MIT` |
| `dev-python/qh3` | `BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD ISC MIT Unicode-3.0 ZLIB openssl` |
| `dev-python/slack-sdk` | `MIT` |
| `dev-python/ua-parser-builtins` | `Apache-2.0` |
| `dev-python/urllib3-future` | `MIT` |
| `dev-util/aws-cdk` | `0BSD Apache-2.0 BSD BSD-2 ISC MIT` |
| `dev-util/cursor-agent` | `all-rights-reserved` |
| `dev-util/github-copilot-bin` | `all-rights-reserved` |
| `dev-util/github-copilot-cli-bin` | `GitHub-Copilot-CLI` |
| `dev-util/mise-bin` | `MIT 0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-1 BSD-2 BZIP2 Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 GPL-2 ISC LGPL-2.1 LGPL-3 MIT-0 MPL-2.0 Unicode-3.0 Unlicense ZLIB openssl` |
| `dev-util/postman-bin` | `all-rights-reserved` |
| `dev-util/semgrep-bin` | `LGPL-2.1+ BZIP2 Apache-2.0 BSD curl || ( GPL-2+ LGPL-3+ ) || ( BSD GPL-2 ) || ( libgcc libstdc++ gcc-runtime-library-exception-3.1 ) || ( LGPL-3+ GPL-2+ ) MIT LGPL-2.1 public-domain ZLIB` |
| `dev-util/trivy` | `Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense public-domain` |
| `net-im/claude-desktop-bin` | `all-rights-reserved` |
| `sci-ml/lm-studio-bin` | `all-rights-reserved` |
| `sys-auth/keycloak-bin` | `Apache-2.0 BSD CC0-1.0 EPL-2.0 MIT POSTGRESQL` |
| `sys-cluster/bom-bin` | `Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0` |
| `sys-cluster/egctl-bin` | `Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0` |
| `sys-cluster/k3s-bin` | `Apache-2.0 BSD MIT BSD BSD-2 CC-BY-SA-4.0 ISC MIT MPL-2.0 POSTGRESQL GPL-2 GPL-3 LGPL-2.1 LGPL-3 ZLIB` |
| `sys-cluster/kubectl-convert` | `Apache-2.0 BSD BSD-2 ISC MIT` |
| `sys-cluster/kubescape-bin` | `0BSD Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense public-domain` |
| `sys-cluster/kustomize-bin` | `Apache-2.0 BSD ISC MIT imagemagick` |
| `sys-process/falco-bin` | `Apache-2.0 BSD BSD-1 BSD-2 curl GPL-2 ISC MIT MPL-2.0 public-domain Unlicense ZLIB || ( public-domain MIT ) || ( LGPL-2.1 BSD-2 ) || ( GPL-2 MIT )` |
| `www-apps/draw-io` | `Apache-2.0 MIT BSD ZLIB EPL-2.0 LGPL-2.1 CC-BY-4.0 OFL-1.1 drawio-icons` |
| `www-apps/open-webui-bin` | `Open-WebUI CC0-1.0 CNRI MIT-0 ZLIB 0BSD Apache-2.0 BSD BSD-2 HPND ISC LGPL-2.1 LGPL-3 LGPL-3+ MIT MPL-2.0 PSF-2 Unlicense ZPL || ( Apache-2.0 BSD ) || ( Apache-2.0 BSD-2 ) || ( Apache-2.0 MIT ) || ( BSD Apache-2.0 ) || ( MPL-2.0 MIT )` |
| `www-apps/owncloud` | `AGPL-3 GPL-2` |
| `www-apps/rt` | `GPL-2` |
| `www-apps/selenium-server-bin` | `Apache-2.0 BSD BSD-2 BZIP2 CDLA-Permissive-2.0 ISC MIT MIT-0 MPL-2.0 Unicode-3.0 ZLIB` |
| `www-client/brave-bin` | `Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0 Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl` |
| `dev-perl/Imager` | `|| ( Artistic GPL-1+ )` |
| `dev-perl/Hash-Merge-Extra` | `|| ( Artistic GPL-1+ )` |
| `dev-perl/DBIx-SearchBuilder` | `|| ( Artistic GPL-1+ )` |
| `dev-perl/Time-ParseDate` | `|| ( Artistic GPL-1+ )` |

## Cleanup evidence

VERIFIED: local metadata evaluation covered 284 packages / 352 ebuilds before pruning, with 356 local dependency edges. Gentoo/Portage atom matching, slots and repository qualifiers were used. Positive dependencies in all USE branches were considered; blockers did not force retention. Starting from the latest ebuild plus all excluded/masked versions, dependency closure required no older version. Deleted 65 unchanged tracked old ebuilds. Final retention validation checked 273 edges with no violation. Detailed plan: `/tmp/codex/overlay-upgrades-20261004/cleanup-plan.json`.

All versions of these packages were excluded from cleanup: `app-editors/nimbalyst-bin`, `dev-util/selenium-ide-bin`, `gui-apps/cauldron`, `sci-geosciences/qgis`, `sci-ml/XNNPACK`, `sys-block/libfabric`, `sys-cluster/ceph`. Single-ebuild packages were skipped. net-analyzer/gsa’s existing 28.5.0 supersedes 28.3.1; this cleanup used only local versions and did not query upstream.

Removed confirmed unused shared files:

- `eclass/n8n-pnpm-deps-2.39.5.eclass`
- `eclass/n8n-pnpm-deps-2.39.8.eclass`
- `eclass/n8n-task-runners-pnpm-deps-2.39.5.eclass`
- `eclass/n8n-task-runners-pnpm-deps-2.39.8.eclass`
- `scripts/locks/openclaw-bin-2026.9.4-package-lock.json`
- `scripts/locks/openclaw-bin-2026.9.5-package-lock.json`
- `licenses/Yandex-Music-EULA`
- `app-misc/n8n/files/n8n-2.39.5-offline-direct-deps.patch`

The actual directory is `eclass/`; `eclasses/` and repository-level `patches/` do not exist. Package patches were checked with PN/P/PF/PV/PVR expansion; referenced patches and all excluded/masked package files remain. No empty files or recursively empty directories existed under package `files/`. Historical docs and active maintainer scripts remain useful even without literal references, so they were retained. Old package license inventories outside the requested shared directories were preserved.

Changed package Manifests were regenerated, including after removal of old ebuilds. Old-only DIST entries may be removed by this authorized regeneration; unrelated package files and excluded/masked package Manifests were preserved. The new support packages have their own metadata.xml and Manifests.

## Official sources and eclass contracts

- [PMS 9](https://projects.gentoo.org/pms/9/pms.html) for EAPI/dependency/keyword semantics and [Gentoo Devmanual EAPI documentation](https://devmanual.gentoo.org/ebuild-writing/eapi/) for packaging guidance. EAPI 9 was confirmed current. Recipes using eclasses that only support EAPI 8 remain at EAPI 8; eclass headers and implementation were inspected, including perl-module and distutils-r1. No stable architecture keywords were introduced.
- Current local eclass documentation/implementation and package examples under `/var/db/repos/gentoo/eclass`, `/var/db/repos/gentoo` and `/var/db/repos/guru`; upstream artifacts remain authoritative for dependencies and licenses.
- [PG0001 optional runtime dependencies](https://projects.gentoo.org/qa/policy-guide/dependencies.html#optional-runtime-dependencies) informed preserving meaningful USE behavior rather than adding flags for optional imports. No new optional-dependency flags were added.
- Exact official upstream release artifacts and APIs recorded above and in `/tmp/report.txt`; no further availability checks during cleanup. Gentoo bug searches yielded no accessible relevant new evidence, so absence of a matching bug is not claimed.

## Files changed

```text
 M app-admin/aws-vault-bin/Manifest
 D app-admin/aws-vault-bin/aws-vault-bin-7.14.0.ebuild
 M app-admin/fluent-bit/Manifest
 D app-admin/fluent-bit/fluent-bit-5.1.2.ebuild
 M app-admin/infracost-bin/Manifest
 D app-admin/infracost-bin/infracost-bin-2.16.3.ebuild
 M app-admin/istioctl-bin/Manifest
 D app-admin/istioctl-bin/istioctl-bin-1.31.0.ebuild
 M app-admin/kiro-cli-bin/Manifest
 D app-admin/kiro-cli-bin/kiro-cli-bin-2.22.0.ebuild
 M app-admin/pulumi-bin/Manifest
 D app-admin/pulumi-bin/pulumi-bin-3.263.0.ebuild
 M app-admin/serverless-bin/Manifest
 D app-admin/serverless-bin/serverless-bin-4.42.0.ebuild
 M app-admin/terragrunt-bin/Manifest
 D app-admin/terragrunt-bin/terragrunt-bin-1.1.5.ebuild
 M app-containers/localstack-cli-bin/Manifest
 D app-containers/localstack-cli-bin/localstack-cli-bin-2026.8.0.ebuild
 M app-containers/lstk-bin/Manifest
 D app-containers/lstk-bin/lstk-bin-1.1.0.ebuild
 M app-editors/cursor/Manifest
 D app-editors/cursor/cursor-3.21.16.ebuild
 M app-editors/kiro/Manifest
 D app-editors/kiro/kiro-1.1.14.ebuild
 M app-editors/sublime-text/Manifest
 D app-editors/sublime-text/sublime-text-4_p4200.ebuild
 M app-misc/chatgpt-bin/Manifest
 D app-misc/chatgpt-bin/chatgpt-bin-26.915.31945.ebuild
 M app-misc/grok-bot-bin/Manifest
 D app-misc/grok-bot-bin/grok-bot-bin-0.57.1.ebuild
 D app-misc/n8n/files/n8n-2.39.5-offline-direct-deps.patch
 M app-misc/openclaw-bin/Manifest
 D app-misc/openclaw-bin/openclaw-bin-2026.9.5.ebuild
 M app-shells/oh-my-posh-bin/Manifest
 D app-shells/oh-my-posh-bin/oh-my-posh-bin-31.3.0.ebuild
 M app-text/koodo-reader-bin/Manifest
 D app-text/koodo-reader-bin/koodo-reader-bin-2.4.4.ebuild
 M dev-db/beekeeper-studio-bin/Manifest
 D dev-db/beekeeper-studio-bin/beekeeper-studio-bin-6.1.2.ebuild
 M dev-db/clickhouse-bin/Manifest
 D dev-db/clickhouse-bin/clickhouse-bin-26.8.8.8.ebuild
 M dev-db/clickhouse-client-bin/Manifest
 D dev-db/clickhouse-client-bin/clickhouse-client-bin-26.8.8.8.ebuild
 M dev-db/clickhouse-common-static-bin/Manifest
 D dev-db/clickhouse-common-static-bin/clickhouse-common-static-bin-26.8.8.8.ebuild
 M dev-db/dbgate-bin/Manifest
 D dev-db/dbgate-bin/dbgate-bin-7.3.0.ebuild
 M dev-db/neo4j-bin/Manifest
 D dev-db/neo4j-bin/neo4j-bin-2026.08.1.ebuild
 M dev-db/opensearch-bin/Manifest
 D dev-db/opensearch-bin/opensearch-bin-3.8.0.ebuild
 M dev-db/postgresql_anonymizer/Manifest
 D dev-db/postgresql_anonymizer/postgresql_anonymizer-3.2.2.ebuild
 M dev-java/groovy-bin/Manifest
 D dev-java/groovy-bin/groovy-bin-5.1.2.ebuild
 M dev-python/boto3-stubs/Manifest
 D dev-python/boto3-stubs/boto3-stubs-1.43.98.ebuild
 M dev-python/jellyfin-apiclient-python/Manifest
 D dev-python/jellyfin-apiclient-python/jellyfin-apiclient-python-1.18.0.ebuild
 M dev-python/jh2/Manifest
 D dev-python/jh2/jh2-5.0.14.ebuild
 M dev-python/mypy-boto3-apigateway/Manifest
 D dev-python/mypy-boto3-apigateway/mypy-boto3-apigateway-1.43.0.ebuild
 M dev-python/mypy-boto3-kinesis/Manifest
 D dev-python/mypy-boto3-kinesis/mypy-boto3-kinesis-1.43.86.ebuild
 M dev-python/mypy-boto3-s3/Manifest
 D dev-python/mypy-boto3-s3/mypy-boto3-s3-1.43.93.ebuild
 M dev-python/niquests/Manifest
 D dev-python/niquests/niquests-3.21.1.ebuild
 M dev-python/ollama-python/Manifest
 D dev-python/ollama-python/ollama-python-0.6.2.ebuild
 M dev-python/pipx/Manifest
 D dev-python/pipx/pipx-1.17.4.ebuild
 M dev-python/qh3/Manifest
 D dev-python/qh3/qh3-2.0.3.ebuild
 M dev-python/slack-sdk/Manifest
 D dev-python/slack-sdk/slack-sdk-3.44.1.ebuild
 M dev-python/ua-parser-builtins/Manifest
 D dev-python/ua-parser-builtins/ua-parser-builtins-202606.ebuild
 M dev-python/urllib3-future/Manifest
 D dev-python/urllib3-future/urllib3-future-2.24.908.ebuild
 M dev-util/aws-cdk/Manifest
 D dev-util/aws-cdk/aws-cdk-2.1142.0.ebuild
 M dev-util/cursor-agent/Manifest
 D dev-util/cursor-agent/cursor-agent-2026.09.18.ebuild
 M dev-util/github-copilot-bin/Manifest
 D dev-util/github-copilot-bin/github-copilot-bin-1.1.22.ebuild
 M dev-util/github-copilot-cli-bin/Manifest
 D dev-util/github-copilot-cli-bin/github-copilot-cli-bin-1.0.86.ebuild
 M dev-util/mise-bin/Manifest
 D dev-util/mise-bin/mise-bin-2026.9.11.ebuild
 M dev-util/postman-bin/Manifest
 D dev-util/postman-bin/postman-bin-12.28.6.ebuild
 M dev-util/semgrep-bin/Manifest
 D dev-util/semgrep-bin/semgrep-bin-1.177.0.ebuild
 M dev-util/trivy/Manifest
 D dev-util/trivy/trivy-0.74.0.ebuild
 D eclass/n8n-pnpm-deps-2.39.5.eclass
 D eclass/n8n-pnpm-deps-2.39.8.eclass
 D eclass/n8n-task-runners-pnpm-deps-2.39.5.eclass
 D eclass/n8n-task-runners-pnpm-deps-2.39.8.eclass
 D licenses/Yandex-Music-EULA
 M net-analyzer/gsa/Manifest
 D net-analyzer/gsa/gsa-28.3.1.ebuild
 M net-im/claude-desktop-bin/Manifest
 D net-im/claude-desktop-bin/claude-desktop-bin-2.2553.1.ebuild
 M sci-ml/lm-studio-bin/Manifest
 D sci-ml/lm-studio-bin/lm-studio-bin-0.4.24_p1.ebuild
 M scripts/generate-open-webui-wheel-deps.py
 M scripts/generate-openclaw-npm-deps.py
 D scripts/locks/openclaw-bin-2026.9.4-package-lock.json
 D scripts/locks/openclaw-bin-2026.9.5-package-lock.json
 M sys-auth/keycloak-bin/Manifest
 D sys-auth/keycloak-bin/keycloak-bin-26.7.4.ebuild
 M sys-cluster/bom-bin/Manifest
 D sys-cluster/bom-bin/bom-bin-0.7.1.ebuild
 M sys-cluster/egctl-bin/Manifest
 D sys-cluster/egctl-bin/egctl-bin-1.9.1.ebuild
 M sys-cluster/k3s-bin/Manifest
 D sys-cluster/k3s-bin/k3s-bin-1.37.0_p1.ebuild
 M sys-cluster/kubectl-convert/Manifest
 D sys-cluster/kubectl-convert/kubectl-convert-1.37.0.ebuild
 M sys-cluster/kubescape-bin/Manifest
 D sys-cluster/kubescape-bin/kubescape-bin-4.0.14.ebuild
 M sys-cluster/kustomize-bin/Manifest
 D sys-cluster/kustomize-bin/kustomize-bin-5.8.1.ebuild
 M sys-process/falco-bin/Manifest
 D sys-process/falco-bin/falco-bin-0.44.1.ebuild
 M www-apps/draw-io/Manifest
 D www-apps/draw-io/draw-io-31.4.6.ebuild
 M www-apps/open-webui-bin/Manifest
 D www-apps/open-webui-bin/open-webui-bin-0.11.3.ebuild
 M www-apps/owncloud/Manifest
 D www-apps/owncloud/owncloud-11.0.0.ebuild
 M www-apps/rt/Manifest
 D www-apps/rt/rt-5.0.10-r1.ebuild
 M www-apps/selenium-server-bin/Manifest
 D www-apps/selenium-server-bin/selenium-server-bin-4.49.0.ebuild
 M www-client/brave-bin/Manifest
 D www-client/brave-bin/brave-bin-1.95.104.ebuild
?? app-admin/aws-vault-bin/aws-vault-bin-7.15.3.ebuild
?? app-admin/fluent-bit/fluent-bit-5.1.3.ebuild
?? app-admin/infracost-bin/infracost-bin-2.17.0.ebuild
?? app-admin/istioctl-bin/istioctl-bin-1.31.1.ebuild
?? app-admin/kiro-cli-bin/kiro-cli-bin-2.27.1.ebuild
?? app-admin/pulumi-bin/pulumi-bin-3.267.0.ebuild
?? app-admin/serverless-bin/serverless-bin-4.43.0.ebuild
?? app-admin/terragrunt-bin/terragrunt-bin-1.1.6.ebuild
?? app-containers/localstack-cli-bin/localstack-cli-bin-2026.8.2.ebuild
?? app-containers/lstk-bin/lstk-bin-1.3.0.ebuild
?? app-editors/cursor/cursor-3.22.12.ebuild
?? app-editors/kiro/kiro-1.2.4.ebuild
?? app-editors/sublime-text/sublime-text-4_p4215.ebuild
?? app-misc/chatgpt-bin/chatgpt-bin-26.930.41038.ebuild
?? app-misc/grok-bot-bin/grok-bot-bin-0.66.0.ebuild
?? app-misc/openclaw-bin/files/openclaw-bin-2026.9.8-third-party-licenses.txt
?? app-misc/openclaw-bin/openclaw-bin-2026.9.8.ebuild
?? app-shells/oh-my-posh-bin/files/NOTICE.deps-31.4.1.txt
?? app-shells/oh-my-posh-bin/oh-my-posh-bin-31.4.1.ebuild
?? app-text/koodo-reader-bin/koodo-reader-bin-2.4.5.ebuild
?? dev-db/beekeeper-studio-bin/beekeeper-studio-bin-6.1.5.ebuild
?? dev-db/clickhouse-bin/clickhouse-bin-26.8.16.41.ebuild
?? dev-db/clickhouse-client-bin/clickhouse-client-bin-26.8.16.41.ebuild
?? dev-db/clickhouse-common-static-bin/clickhouse-common-static-bin-26.8.16.41.ebuild
?? dev-db/dbgate-bin/dbgate-bin-7.3.1.ebuild
?? dev-db/neo4j-bin/neo4j-bin-2026.09.0.ebuild
?? dev-db/opensearch-bin/opensearch-bin-3.9.0.ebuild
?? dev-db/postgresql_anonymizer/postgresql_anonymizer-3.2.3.ebuild
?? dev-java/groovy-bin/groovy-bin-6.0.0.ebuild
?? dev-perl/DBIx-SearchBuilder/DBIx-SearchBuilder-1.850.0.ebuild
?? dev-perl/DBIx-SearchBuilder/Manifest
?? dev-perl/DBIx-SearchBuilder/metadata.xml
?? dev-perl/Hash-Merge-Extra/Hash-Merge-Extra-0.60.0.ebuild
?? dev-perl/Hash-Merge-Extra/Manifest
?? dev-perl/Hash-Merge-Extra/metadata.xml
?? dev-perl/Imager/Imager-1.37.0.ebuild
?? dev-perl/Imager/Manifest
?? dev-perl/Imager/metadata.xml
?? dev-perl/Time-ParseDate/Manifest
?? dev-perl/Time-ParseDate/Time-ParseDate-2026.33.0.ebuild
?? dev-perl/Time-ParseDate/metadata.xml
?? dev-python/boto3-stubs/boto3-stubs-1.43.108.ebuild
?? dev-python/jellyfin-apiclient-python/jellyfin-apiclient-python-1.19.0.ebuild
?? dev-python/jh2/jh2-5.0.15.ebuild
?? dev-python/mypy-boto3-apigateway/mypy-boto3-apigateway-1.43.100.ebuild
?? dev-python/mypy-boto3-kinesis/mypy-boto3-kinesis-1.43.101.ebuild
?? dev-python/mypy-boto3-s3/mypy-boto3-s3-1.43.106.ebuild
?? dev-python/niquests/niquests-3.21.2.ebuild
?? dev-python/ollama-python/ollama-python-0.6.3.ebuild
?? dev-python/pipx/pipx-1.17.11.ebuild
?? dev-python/qh3/qh3-2.0.4.ebuild
?? dev-python/slack-sdk/slack-sdk-3.45.0.ebuild
?? dev-python/ua-parser-builtins/ua-parser-builtins-202610.ebuild
?? dev-python/urllib3-future/urllib3-future-2.25.901.ebuild
?? dev-util/aws-cdk/aws-cdk-2.1144.0.ebuild
?? dev-util/cursor-agent/cursor-agent-2026.10.01.ebuild
?? dev-util/github-copilot-bin/github-copilot-bin-1.1.26.ebuild
?? dev-util/github-copilot-cli-bin/github-copilot-cli-bin-1.0.91.ebuild
?? dev-util/mise-bin/mise-bin-2026.10.1.ebuild
?? dev-util/postman-bin/postman-bin-12.30.6.ebuild
?? dev-util/semgrep-bin/semgrep-bin-1.179.0.ebuild
?? dev-util/trivy/trivy-0.75.0.ebuild
?? docs/overlay-upgrade-review-2026-10-04.md
?? licenses/Indiana-Extreme-1.2
?? net-im/claude-desktop-bin/claude-desktop-bin-2.9939.4.ebuild
?? sci-ml/lm-studio-bin/lm-studio-bin-0.4.25_p1.ebuild
?? scripts/locks/openclaw-bin-2026.9.8-package-lock.json
?? sys-auth/keycloak-bin/keycloak-bin-26.8.0.ebuild
?? sys-cluster/bom-bin/bom-bin-0.8.0.ebuild
?? sys-cluster/egctl-bin/egctl-bin-1.9.2.ebuild
?? sys-cluster/k3s-bin/k3s-bin-1.37.1_p1.ebuild
?? sys-cluster/kubectl-convert/kubectl-convert-1.37.1.ebuild
?? sys-cluster/kubescape-bin/kubescape-bin-4.0.15.ebuild
?? sys-cluster/kustomize-bin/kustomize-bin-5.8.2.ebuild
?? sys-process/falco-bin/falco-bin-0.45.0.ebuild
?? www-apps/draw-io/draw-io-32.0.2.ebuild
?? www-apps/open-webui-bin/open-webui-bin-0.11.4.ebuild
?? www-apps/owncloud/owncloud-11.0.1.ebuild
?? www-apps/rt/rt-6.0.3.ebuild
?? www-apps/selenium-server-bin/selenium-server-bin-4.50.0.ebuild
?? www-client/brave-bin/brave-bin-1.96.61.ebuild
```

Full audit workspaces: `/tmp/codex/<category>/<package>-<new version>/upgrade-audit-20261004`; aggregate commands/results: `/tmp/codex/overlay-upgrades-20261004`. Temporary phase trees were cleaned after validation; logs and static evidence remain. Remote staging was confined to package workspaces under `/tmp/codex`, and no remote overlay checkout was modified.

## Follow-up: RT security and OpenClaw image corrections

Applied RT’s missing CVE-2026-41073 TSV header mitigation, added its File-Which runtime dependency, preserved webapp.eclass’s inherited dependency by appending to DEPEND, restored OpenClaw’s executable permissions, and removed foreign pi-tui prebuilds. Keywords, USE flags and LICENSE values are unchanged.

### RT security and dependency evidence

VERIFIED: [Best Practical’s RT 6.0.3 advisory](https://forum.bestpractical.com/t/rt-6-0-3-released/41646) identifies the omitted TSV header fix and recommends [commit 525547751b76cc422015960bae3056f4e8d4351f](https://github.com/bestpractical/rt/commit/525547751b76cc422015960bae3056f4e8d4351f.patch). The patch in FILESDIR is byte-identical to that upstream patch. SHA-256: `2872e8aebcf07ea968efcebd1b628c7efbc6f6358679f1435c1cebbe51e5db72`. It applies in src_prepare before the existing Gentoo install-serialization patch. No revision bump was needed for this still-uncommitted new ebuild.

File::Which is used by the installed GnuPG and S/MIME modules, as independently inspected in [the exact RT 6.0.3 distfile](https://download.bestpractical.com/pub/rt/release/rt-6.0.3.tar.gz): `etc/cpanfile`, `lib/RT/Crypt/GnuPG.pm`, `lib/RT/Crypt/SMIME.pm`. The existing package already declares their other dependencies; no convenience USE flag was added. [Gentoo File-Which-1.270.0-r1](/var/db/repos/gentoo/dev-perl/File-Which/File-Which-1.270.0-r1.ebuild) has both `amd64` and `arm64` keywords. The dependency assignment now preserves `app-admin/webapp-config`, following `/var/db/repos/gentoo/eclass/webapp.eclass`’s WEBAPP_DEPEND contract. This final metadata-only append was checked by the final scoped scan; the phase-tested preparation/configuration/install code is unchanged.

VERIFIED: direct checks and literal output:

```text
patch --dry-run -p1: exit 0
checking file share/html/Elements/TSVExport
perl tsv-security-check.pl: exit 0
TSV header regression: 5 formula/quote prefixes escaped; 2 ordinary headers unchanged
```

VERIFIED: RT completed clean/unpack/prepare/configure/compile/install phase sequences on both hosts after eight Perl dependency packages were built into temporary images and exposed through temporary PERL5LIB. The dependencies were Set-Infinite, DateTime-Set, Clone-Choose, Hash-Merge, DBIx-SearchBuilder, Hash-Merge-Extra, Imager and Time-ParseDate. All eight dependency phase sequences also returned exit 0 on each architecture. The four additional Gentoo dependencies were staged for validation; no new copies were added to the overlay.

The first retries against the installed host dependencies still failed with the six missing Perl modules recorded above. Passing PERL5LIB only in the process environment was filtered by Portage. The final checks used PORTAGE_CONFIGROOT under the RT/dependency temporary workspaces with a bashrc exporting only staged library paths; the existing profile was referenced read-only. The perl-functions.eclass implementation’s explicit I_KNOW_WHAT_I_AM_DOING override allowed this deliberate temporary validation environment and retained its diagnostic messages. No live Portage configuration was edited. This is a validation setup, not an ebuild workaround or a recommendation for normal installation.

RT validation used postgres/apache with mysql, lighttpd, nginx, fastcgi and graphviz disabled. Thus the remaining USE alternatives are NOT VERIFIED. Exact commands, temporary configuration and PERL5LIB paths are in `/tmp/codex/overlay-upgrades-20261004/rt-closure-results.json`. Literal result excerpts:

**server01 / amd64**, phase command exit 0:

```text
All dependencies found.
>>> Completed installing www-apps/rt-6.0.3 into /tmp/codex/www-apps/rt-6.0.3/followup-59951144/closure-amd64-38dc6627/build/portage/www-apps/rt-6.0.3/image
 * Final size of installed tree:  53160 KiB (51.9 MiB)
RT image files: 2415
Patched template: usr/share/webapps/rt/6.0.3/htdocs/Elements/TSVExport
Temporary library paths in installed files: []
```

**gentoo / arm64**, phase command exit 0:

```text
All dependencies found.
>>> Completed installing www-apps/rt-6.0.3 into /tmp/codex/www-apps/rt-6.0.3/followup-59951144/closure-arm64-87764533/build/portage/www-apps/rt-6.0.3/image
 * Final size of installed tree:  53160 KiB (51.9 MiB)
RT image files: 2415
Patched template: usr/share/webapps/rt/6.0.3/htdocs/Elements/TSVExport
Temporary library paths in installed files: []
```

NOT VERIFIED: RT application behavior against a real database, upgrade/migration, web-server integration, all USE alternatives, and complete upstream test suites. No database initialization, service activation, merge or live installation was performed.

### OpenClaw executable and architecture checks

Upstream archive modes are preserved during extraction, but doins normalized all regular files to 0644. src_install now enumerates the extracted installed payload’s executable files and uses fperms 0755 after doins. Ordinary data files retain normal doins permissions. This restores esbuild, npm commands and other archived executables.

Inspection of [pi-tui 0.86.1’s exact npm archive](https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.86.1.tgz) established the loader’s `native/<platform>/prebuilds/<platform>-<arch>` layout. src_prepare removes Darwin/Windows prebuilds and the other Linux architecture, while asserting that the selected Linux helper exists. Both retained Linux helpers have `NEEDED libxcb.so.1`; x11-libs/libxcb is now a direct runtime dependency. No native binary was modified to mask an ABI mismatch.

VERIFIED: full temporary-image phase sequences and additional image checks returned exit 0 on server01/amd64 and gentoo/arm64. Literal image-check output:

**server01 / amd64**:

```text
esbuild --version: 0.28.2
pi-tui native helper: getText and getImage loaded
{"arch": "amd64", "restored_executables_checked": 94, "mode_violations": [], "pi_tui_native_helpers": ["node_modules/@earendil-works/pi-tui/native/linux/prebuilds/linux-x64/linux-platform-x11.node"], "elf_machine": 62, "esbuild_version": "0.28.2", "native_load_exit": 0}
```

**gentoo / arm64**:

```text
esbuild --version: 0.28.2
pi-tui native helper: getText and getImage loaded
{"arch": "arm64", "restored_executables_checked": 95, "mode_violations": [], "pi_tui_native_helpers": ["node_modules/@earendil-works/pi-tui/native/linux/prebuilds/linux-arm64/linux-platform-x11.node"], "elf_machine": 183, "esbuild_version": "0.28.2", "native_load_exit": 0}
```

The checker compares modes for every archived executable in the installed payload, requires exactly one pi-tui native helper at the selected Linux path, checks ELF e_machine, runs the retained esbuild binary, and loads the pi-tui helper with Node to check getText/getImage exports. DISPLAY was unset; clipboard operations were not invoked. The initial checker incorrectly assumed a spawn-helper existed in this release; it was corrected against the exact archive listing, then both images were rebuilt and checked again. Earlier logs remain in the follow-up workspace as `.initial` files.

NOT VERIFIED: full OpenClaw workflows, external services/cloud APIs, model integrations, interactive terminal/clipboard behavior, and other optional native modules.

### Arm64 dependency exceptions

VERIFIED: 51 dependency atoms named by the scoped scan lack any matching arm64-keyworded ebuild in the available repositories. They affect RT, Hash-Merge-Extra and DBIx-SearchBuilder. [The updated arm64 dependency record](rt-arm64-validation.md) lists each atom, consumers, exact matching Gentoo/GURU ebuild paths and literal KEYWORDS. File-Which has both target keywords and introduces no exception. No global or package keyword overrides were added.

These are explicitly documented personal-overlay exceptions to normal arm64 dependency solvability. Native image construction with staged libraries does not make the normal arm64 Portage resolver closure usable. The current ~arm64 declarations are preserved under the user’s keyword policy; validating and keywording the missing dependency closure remains separate work.

### Manifest and scoped QA results

VERIFIED: both affected Manifests were regenerated with pkgdev manifest using the package-specific distfile caches. Both commands returned exit 0 and printed `manifests are up to date`. No DIST checksums changed in this follow-up; the repository uses `thin-manifests = true`, so local patch files do not add AUX entries.

```text
bash -n www-apps/rt/rt-6.0.3.ebuild: exit 0
bash -n app-misc/openclaw-bin/openclaw-bin-2026.9.8.ebuild: exit 0
git diff --check: exit 0; output: ''
pkgcheck scan (six affected/related local packages): exit 0
```

Exact QA command:

```text
pkgcheck scan --cache-dir /tmp/codex/overlay-upgrades-20261004/pkgcheck-cache www-apps/rt app-misc/openclaw-bin dev-perl/Imager dev-perl/Hash-Merge-Extra dev-perl/DBIx-SearchBuilder dev-perl/Time-ParseDate
```

The scan still reports the documented arm64 keyword gaps and OpenClaw’s existing musl/x32 profile limitations. It has no new nonexistent dependency or unknown-license finding. Literal final scoped output:

```text
dev-perl/DBIx-SearchBuilder
  NonsolvableDepsInDev: version 1.850.0: nonsolvable depset(bdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInDev: version 1.850.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInStable: version 1.850.0: nonsolvable depset(bdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]
  NonsolvableDepsInStable: version 1.850.0: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ >=dev-perl/Cache-Simple-TimedExpiry-0.210.0, >=dev-perl/Class-ReturnValue-0.400.0, dev-perl/DBIx-DBSchema, dev-perl/Want, >=dev-perl/capitalization-0.30.0 ]

dev-perl/Hash-Merge-Extra
  NonsolvableDepsInDev: version 0.60.0: nonsolvable depset(bdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInDev: version 0.60.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInStable: version 0.60.0: nonsolvable depset(bdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Hash-Merge ]
  NonsolvableDepsInStable: version 0.60.0: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Hash-Merge ]

app-misc/openclaw-bin
  NonsolvableDepsInDev: version 2026.9.8: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.9.8: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32) (3 total): solutions: [ <net-libs/nodejs-25, >=net-libs/nodejs-24.16.0, >=net-libs/nodejs-26.1.0 ]
  RequiredUseDefaults: version 2026.9.8: profile: 'default/linux/amd64/23.0/musl' (18 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.9.8: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (18 total)

www-apps/rt
  NonsolvableDepsInDev: version 6.0.3: nonsolvable depset(depend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2 ]
  NonsolvableDepsInDev: version 6.0.3: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (27 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2, www-servers/spawn-fcgi ]
  NonsolvableDepsInStable: version 6.0.3: nonsolvable depset(depend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2 ]
  NonsolvableDepsInStable: version 6.0.3: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (36 total): solutions: [ dev-perl/Apache-DBI, >=dev-perl/Apache-Session-1.530.0, dev-perl/Business-Hours, dev-perl/CGI-PSGI, dev-perl/CSS-Minifier-XS, >=dev-perl/CSS-Squish-0.60.0, dev-perl/Convert-Color, dev-perl/Crypt-Eksblowfish, dev-perl/Crypt-X509, dev-perl/Data-GUID, dev-perl/Data-ICal, dev-perl/Data-Page, >=dev-perl/Date-Extract-0.70.0, dev-perl/DateTime-Set, >=dev-perl/Email-Address-List-0.60.0, dev-perl/GnuPG-Interface, dev-perl/GraphViz2, dev-perl/HTML-FormatExternal, dev-perl/HTML-FormatText-WithLinks, dev-perl/HTML-FormatText-WithLinks-AndTables, dev-perl/HTML-Gumbo, dev-perl/HTML-Mason, dev-perl/HTML-Mason-PSGIHandler, dev-perl/HTML-Quoted, dev-perl/HTML-RewriteAttributes, dev-perl/Hash-Merge, dev-perl/JavaScript-Minifier-XS, dev-perl/Locale-Maketext-Fuzzy, >=dev-perl/Module-Versions-Report-1.50.0, dev-perl/MooseX-NonMoose, >=dev-perl/Path-Dispatcher-1.70.0, dev-perl/PerlIO-eol, dev-perl/Regexp-Common-net-CIDR, >=dev-perl/Role-Basic-0.120.0, dev-perl/Scope-Upper, dev-perl/Starlet, >=dev-perl/Symbol-Global-Name-0.50.0, dev-perl/Text-Password-Pronounceable, >=dev-perl/Text-Quoted-2.80.0, >=dev-perl/Text-WikiFormat-0.760.0, dev-perl/Text-WordDiff, dev-perl/Text-Wrapper, >=dev-perl/Tree-Simple-1.40.0, >=dev-perl/Web-Machine-0.120.0, >=www-apache/mod_perl-2, www-servers/spawn-fcgi ]
```

### Files and logs

- `www-apps/rt/rt-6.0.3.ebuild`: patch application, File-Which, inherited webapp dependency preservation.
- `www-apps/rt/files/rt-6.0.3-CVE-2026-41073.patch`: exact upstream security fix.
- `app-misc/openclaw-bin/openclaw-bin-2026.9.8.ebuild`: executable modes, pi-tui pruning and direct libxcb dependency.
- `docs/rt-arm64-validation.md`: explicit current dependency keyword exceptions and native phase validation.
- `docs/overlay-upgrade-review-2026-10-04.md` and `/tmp/report.txt`: updated outcomes and evidence.
- Both affected Manifests were regenerated; their contents remain unchanged from the start of this follow-up.

Raw OpenClaw phase/image-check logs and RT security/regression logs:

- `/tmp/codex/app-misc/openclaw-bin-2026.9.8/followup-ecf83635`
- `/tmp/codex/www-apps/rt-6.0.3/followup-59951144`

Aggregate evidence: `followup-build-results.json`, `rt-closure-results.json`, `followup-manifest-results.json`, `pkgcheck-followup-result.json`, `arm64-exceptions.json` under `/tmp/codex/overlay-upgrades-20261004`. Dependency workspaces and exact upstream artifact URLs are in `rt-validation-deps.json`. Native remote logs/results were copied back to this machine; remote work remained under package-specific /tmp/codex directories. Temporary images were cleaned after checking.

Official contracts consulted: current PMS/Devmanual, `/var/db/repos/gentoo/eclass/webapp.eclass`, `/var/db/repos/gentoo/eclass/perl-functions.eclass`, and Portage’s `doebuild.py`/`ebuild.sh` handling of PORTAGE_CONFIGROOT/bashrc. Gentoo bug searches were attempted but bugs.gentoo.org blocked access; no claim of absence of a matching bug is made. No new upstream release-availability checks were made. No commit, push, branch, merge or live-system package installation was performed.
