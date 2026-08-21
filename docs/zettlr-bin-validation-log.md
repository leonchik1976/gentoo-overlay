# app-text/zettlr-bin validation log

Concise, factual record of real build/install validation actually
performed for `app-text/zettlr-bin-4.7.0` (this overlay never runs
`emerge`/`merge`/`qmerge` — validation stops at `ebuild ... install`, per
this repo's CLAUDE.md). Full raw build logs were kept at
`/tmp/claude/zettlr-arm64-build.log` and `/tmp/claude/zettlr-amd64-build.log`
on their respective hosts at the time of this run; that location is
ephemeral, so treat this file as the durable record.

## 2026-08-21 — final ebuild (python-any-r1 conversion, hardened asar-strip-dict.py with built-in SHA256 integrity verification)

Both rows below are from actual, complete `ebuild ... install` runs
against the current script (the one with built-in per-file SHA256
verification), each with its own persisted raw log. An earlier version of
this table asserted the arm64 result before a matching post-hardening
arm64 run had actually been logged — the arm64 row was re-run and its log
replaced to close that gap; both rows are now genuinely evidenced.

| | arm64 | amd64 |
|---|---|---|
| Host | this host (native) | server01 (ssh) |
| Command | `ebuild zettlr-bin-4.7.0.ebuild clean unpack prepare configure compile install` | same, via ssh |
| **Effective USE** (`build-info/USE`) | `arm64 elibc_glibc kernel_linux l10n_en-US l10n_he l10n_ru` | (not captured separately — same package, no relevant IUSE beyond arch/l10n/elibc/kernel) |
| Python selected (`python-any-r1`, `PYTHON_COMPAT=( python3_{12..15} )`) | python3.14 (via PYTHON_COMPAT iteration) | python3.14 (via PYTHON_COMPAT iteration) |
| `files/asar-strip-dict.py` result | `removed 2 file(s) (9296470 bytes) under /.webpack/main/dict/tr-TR; 425 surviving file(s) integrity-verified (SHA256); resources/app.asar is now 65551437 bytes` | identical, including the 425-file integrity-verified count |
| Result | exit 0, `>>> Completed installing` | exit 0, `>>> Completed installing` |
| `merge`/`qmerge`/`emerge` run? | no | no |

Confirms the `python-any-r1`/`${PYTHON}`/`${PYTHON_DEPS}` conversion (from
a hardcoded `python3` call) selects an interpreter correctly on both
arches, and that the hardened `asar-strip-dict.py` now cryptographically
verifies (SHA256, whole-file and per-block, against each file's own
stored `integrity` block — the same check Electron's own
`asar-fs-wrapper` performs) every one of the 425 surviving files on
*every* run, on both arches, not just as a one-off check done before it
was wired into `src_prepare()` — see "Hardening pass" in
`docs/zettlr-bin-license-audit.md` for what this does and doesn't prove.
`/opt/zettlr/Zettlr` confirmed present in the installed tree on both
hosts; the `.py` helper itself correctly does not end up in the installed
image (it only touches `${WORKDIR}`, never copied by `src_install`'s
`cp -a`).
