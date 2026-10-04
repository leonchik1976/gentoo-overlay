# Anki security backport validation — 2026-10-04

## Result and scope

The authorized source-backport option was used. `app-misc/anki-25.09.2` retains
only `~arm64`, with the applicable upstream application security fixes shipped
through 26.09.3 and the Rustls TLS advisory update. It is not relabeled 26.09.3
and does not include that release's unrelated features or complete dependency
refresh. This is a temporary personal-overlay package.

The 26.09.3 source and release metadata were inspected. Its Rust dependency
archive exists at gentoo-crate-dist, but the current Gentoo-maintainer frontend
archive directory provides 26.05, not an exact 26.09.3 archive. Backporting avoids
introducing an unhosted dependency bundle or building with mismatched frontend
locks. The older package's existing offline archives remain in use, supplemented
by two exact fixed Rust crate distfiles.

## Files changed in this repair

- `app-misc/anki/anki-25.09.2.ebuild`: add fixed Rust crates and security patches;
  preserve `KEYWORDS="~arm64"` and appended inherited BDEPEND.
- `app-misc/anki/Manifest`: add rustls and rustls-webpki distfile entries.
- `app-misc/anki/files/anki-25.09.2-security.patch`: production backport.
- `app-misc/anki/files/anki-25.09.2-security-tests.patch`: upstream regression tests.
- `scripts/tests/anki/test_security_backport.py`: additional boundary tests.
- `scripts/tests/anki/qwebengine_csp_smoke.py`: upstream offscreen browser test,
  with its prepared source root supplied through `ANKI_TEST_SOURCE`.
- `scripts/tests/anki/README.md`: test instructions.
- `docs/anki-security-backport-validation.md`: this evidence report.
- `docs/rt-arm64-validation.md`: RT dependency keyword gaps and build evidence.

Earlier uncommitted GSA, RT, WorkSpaces and Anki work was preserved. No old
package versions or existing Manifest entries were removed. GSA stays arm64-only;
WorkSpaces retains its mandatory `sys-libs/libselinux` dependency. No commit,
branch, push, PR, live-system merge or installation was performed.

## Upstream security scope and adaptations

| Upstream advisory/fix | Backport |
| --- | --- |
| [GHSA-78wr-2gg2-4hqg](https://github.com/ankitects/anki/security/advisories/GHSA-78wr-2gg2-4hqg) | Builtin/local file path containment checks and safe error handling from the 25.09.4 maintenance branch. |
| [GHSA-869j-r97x-hx2g](https://github.com/ankitects/anki/security/advisories/GHSA-869j-r97x-hx2g) | Host/origin rejection at the local HTTP server boundary from 25.09.4. |
| [GHSA-cw6h-ffmh-x6vh](https://github.com/ankitects/anki/security/advisories/GHSA-cw6h-ffmh-x6vh) | Untrusted collection-media CSP; scripts, forms and network access blocked while preserving presentation resources using upstream's later regression fix. |
| [GHSA-jw6j-j4mf-8jgm](https://github.com/ankitects/anki/security/advisories/GHSA-jw6j-j4mf-8jgm) | Frame-ancestor restrictions on internal pages, form restrictions and script hashes for the untrusted image-occlusion page. |
| [GHSA-932p-crhj-v43p](https://github.com/ankitects/anki/security/advisories/GHSA-932p-crhj-v43p) | Common legacy image-menu entry point rejects non-image extensions. The new editor's TS handler and new openMedia endpoint do not exist in 25.09.2, so they are not introduced. |
| [GHSA-m5rf-76jh-mgwp](https://github.com/ankitects/anki/security/advisories/GHSA-m5rf-76jh-mgwp) | Exact current upstream Rust empty-card-report stripping of active HTML from note/card type names. |
| [26.09.2 navigation guard](https://github.com/ankitects/anki/commit/7add01b1bc89d81126b47b235ee24402159fce02) and [token origin restriction](https://github.com/ankitects/anki/commit/83254832b0fbe00602b5a6381c78ae59ccaf6c25) | Internal-navigation exemptions and bearer credentials restricted to the actual server scheme/authority, retaining the old route helper names. |
| [RUSTSEC-2026-0285](https://rustsec.org/advisories/RUSTSEC-2026-0285.html) | Rustls 0.23.45 and rustls-webpki 0.103.15, exactly as selected by upstream's [advisory update](https://github.com/ankitects/anki/commit/a39e1b7ee3b28b61bf07a40c66bab1315eff5889). Existing compatible dependency graph retained. |

[GHSA-wfww-9gq3-jg46](https://github.com/ankitects/anki/security/advisories/GHSA-wfww-9gq3-jg46)
is recorded by upstream as affecting versions before 24.06; it is not an omitted
applicable backport to the 25.09.2 baseline. The upstream chacha20 update concerned
a yanked 0.10.0 version that is not in the baseline Cargo.lock; it was not copied.

Production patch headers link the exact upstream commits and explain adaptations.
The current upstream SvelteKit CSP hash configuration was backported so the
occlusion page's legitimate bootstrap script works under the restricted policy.
Runtime modules were compared against the final split patches; they matched
with only a duplicate `import re` normalized. The final patch omits that duplicate.
The final split patches applied to a fresh upstream source copy without errors.

The large initial patch exceeded pkgcheck file-size guidance. It was split into
production and upstream tests, with the standalone browser test in repository
maintainer tooling. Final sizes are below 20 KiB per patch and below 50 KiB for
this package's files directory; no QA suppression was introduced.

## VERIFIED — build results

Native arm64 host: `gentoo`. Python: 3.14. No amd64 Anki build was run or claimed;
this package is deliberately arm64-only. EAPI 8 retained because the current
inherited cargo and distutils-r1 eclasses support EAPI 8 only.

Command, executed over SSH against the staged repository under the package
workspace:

```sh
PORTAGE_TMPDIR=/tmp/codex/app-misc/anki-25.09.2 \
  ebuild /tmp/codex/app-misc/anki-25.09.2/validation-repo/app-misc/anki/anki-25.09.2.ebuild \
  clean fetch unpack prepare configure compile install
```

Exit 0. Literal output:

```
>>> Completed installing app-misc/anki-25.09.2 into /tmp/codex/app-misc/anki-25.09.2/portage/app-misc/anki-25.09.2/image
* Verifying compiled files for python3.14
```

Source and frontend were compiled offline, including the fixed Rustls crates.
The image's actual image-occlusion bootstrap hash was checked by the regression
suite. Log copied back to server01:
`/tmp/codex/app-misc/anki-25.09.2/security-build-arm64.log`.

RT completed installation to its temporary image on **both** amd64/server01 and
arm64/gentoo. Configure/compile logs had already reported `All dependencies found.`;
RT's compile function is a no-op. The ownership failure was an unprivileged
validation-runner issue. This retry allowed the upstream ownership operations:

```sh
sudo -n env PORTAGE_TMPDIR=/tmp/codex/www-apps/rt-5.0.10 \
  ebuild <local-or-staged-rt-5.0.10-r1.ebuild> install
```

Both retries exited 0 and printed:

```
>>> Completed installing www-apps/rt-5.0.10-r1 into /tmp/codex/www-apps/rt-5.0.10/portage/www-apps/rt-5.0.10-r1/image
```

Logs on server01: `/tmp/codex/www-apps/rt-5.0.10/image-amd64-retry.log` and
`image-arm64-retry.log`. Neither install phase was a live-system merge. No RT
configuration, database initialization, or service startup was performed.

GSA and WorkSpaces were unchanged during this repair; their earlier arm64/source
and amd64/binary-image validations respectively were not rerun. GSA amd64 and
WorkSpaces arm64 remain untested and unkeyworded, as intended.

## VERIFIED — test results (separate from builds)

Tests ran on native arm64/gentoo. The ebuild's full test suite was not enabled;
focused security checks were run explicitly after the image-only build.

Environment: `TMPDIR` under the package workspace, `PYTHONDONTWRITEBYTECODE=1`,
`QT_QPA_PLATFORM=offscreen`, `ANKI_TEST_MODE=1`, and `PYTHONPATH` pointing to the
image's Python 3.14 site-packages.

```sh
python3.14 -m pytest -q -o addopts= \
  -o cache_dir=/tmp/codex/app-misc/anki-25.09.2/pytest-cache \
  /tmp/codex/app-misc/anki-25.09.2/test_mediasrv_final.py \
  /tmp/codex/app-misc/anki-25.09.2/test_security_backport.py
```

Final test file is the upstream regression file produced by the final split
patch. Exit 0; literal output:

```
65 passed in 0.40s
```

An earlier run reported `65 passed, 1 deselected in 0.79s`; its one deselection
was an unrelated missing-Content-type-header regression added after the baseline.
That unrelated test is explicitly omitted from the final backported test file.
There are no deselections in the final run.

Upstream offscreen browser fixture check, with `ANKI_TEST_SOURCE` pointing to the
prepared source tree and TMPDIR under the package workspace:

```sh
python3.14 /tmp/codex/app-misc/anki-25.09.2/qwebengine_csp_smoke.py
```

Exit 0; literal output:

```
QtWebEngine CSP smoke test passed (reviewer, editor, editor-sveltekit, image-occlusion-csp-inline).
```

These test pages and temporary collections are fixtures, not real user data.
The full upstream Rust/Python/JS suites were **not** run; the Rust regression
cases included in the patch were not independently run through cargo test.
The compiled backend's empty-card-report behavior was exercised from Python.
No normal Anki session or manual GUI interaction was performed.

RT's database-dependent upstream integration tests were **not** run. The ebuild
has `RESTRICT="test"`; image completion is build validation, not an integration
test. No new GSA or WorkSpaces application tests were performed in this repair.

Test logs on server01:
`/tmp/codex/app-misc/anki-25.09.2/security-pytest-final-arm64.log` and
`security-csp-smoke-arm64.log`.

## VERIFIED — Manifests and targeted QA

```sh
pkgdev manifest -d /tmp/codex/app-misc/anki-25.09.2/security/crates app-misc/anki www-apps/rt
pkgcheck scan --cache-dir /tmp/codex/app-misc/anki-25.09.2/pkgcheck-cache \
  app-misc/anki www-apps/rt net-analyzer/gsa net-misc/amazon-workspaces-bin
bash -n app-misc/anki/anki-25.09.2.ebuild www-apps/rt/rt-5.0.10-r1.ebuild
git diff --check
```

Anki Manifest initially printed `* generating manifest: app-misc/anki::local`;
final checks printed `manifests are up to date`. Added entries are the two fixed
crate distfiles. RT's Manifest content did not change. Existing GSA/WorkSpaces
Manifests were preserved.

Final targeted scan exited 0, but is **not** described as clean. Findings:

```
RedundantVersion: version 28.3.1: slot(0) keywords are overshadowed by version: 28.5.0
PythonCompatUpdate: version 25.09.2: PYTHON_COMPAT update available: python3_15
```

RT still reports `NonsolvableDepsInDev` and `NonsolvableDepsInStable` for its
arm64 dependency keyword gaps. Exact atoms and local acceptance guidance are in
`docs/rt-arm64-validation.md`. These predate this repair; the chosen authorized
resolution is documentation. No unrelated package keywords were invented.
The earlier new patch-size findings were resolved by the split; they are absent
from the final scan. Python 3.15 was not added without validation. Bash syntax
and diff whitespace checks exited 0 with no output.

Full scan log: `/tmp/codex/app-misc/anki-25.09.2/security-pkgcheck-final.log`.

## Sources and remaining limits

Version/dependency/license evidence:

- [Upstream 26.09.3 release API](https://api.github.com/repos/ankitects/anki/releases/tags/26.09.3)
  and [exact source artifact](https://github.com/ankitects/anki/archive/refs/tags/26.09.3.tar.gz).
- [25.09.2 source](https://github.com/ankitects/anki/archive/refs/tags/25.09.2.tar.gz),
  [25.09.2 to 25.09.4 security baseline](https://github.com/ankitects/anki/compare/25.09.2...25.09.4),
  [upstream advisory API](https://api.github.com/repos/ankitects/anki/security-advisories).
- [rustls 0.23.45 distfile](https://static.crates.io/crates/rustls/rustls-0.23.45.crate)
  and [rustls-webpki 0.103.15 distfile](https://static.crates.io/crates/rustls-webpki/rustls-webpki-0.103.15.crate):
  shipped Cargo.toml dependency requirements and license files inspected.
  Rustls declares `Apache-2.0 OR ISC OR MIT`; rustls-webpki declares `ISC`,
  all already covered by the ebuild's LICENSE.
  Exact versions/checksums come from upstream Anki 26.09.3 Cargo.lock; crate
  dependency constraints fit the retained lock graph and were confirmed by the build.
- `::gentoo/app-misc/anki/anki-25.09.2.ebuild` and its four existing patches provide
  the source-build baseline. No third-party overlay pins or license values copied.
- [Frontend archive directory](https://home.cit.tum.de/~salu/distfiles/) and
  [gentoo-crate-dist release API](https://api.github.com/repos/gentoo-crate-dist/anki/releases)
  were inspected to assess source-update feasibility.
- Current `/var/db/repos/gentoo/eclass/cargo.eclass` implementation was consulted
  for CRATES handling, crate unpacking, vendored offline configuration, and EAPI
  support. [PMS 9](https://projects.gentoo.org/pms/9/pms.html) and
  [Devmanual EAPI guidance](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html)
  remain the semantics references; the required eclasses limit this package to 8.
- [Portage keyword documentation](https://dev.gentoo.org/~zmedico/portage/doc/man/portage.5.html)
  confirms `**` ignores KEYWORDS; the RT document describes narrowly chosen local
  overrides, not a blanket recommendation or official arm64 keyword claim.

Gentoo bug searches for Anki security/26.09 returned no relevant report in the
search results; absence of a result is not proof that no bug exists. Upstream
advisories and exact source commits guided the repair.

INFERRED: the backport implements the listed upstream security boundaries on the
older architecture, with adaptations documented above. Tests give evidence for
those boundaries; they do not prove absence of every vulnerability.

NOT VERIFIED: other Anki Python implementations, amd64 Anki, full test suites,
manual GUI behavior and existing-user-profile/add-on compatibility. RT runtime
integration and upstream dependency keywording remain administrator/upstream work.
