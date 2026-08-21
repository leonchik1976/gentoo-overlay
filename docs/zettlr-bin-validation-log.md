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

## 2026-08-21 — directory-permission correction

### Defect and pre-change inspection

On `server01`, the installed launcher failed for an ordinary user with
`bash: /opt/bin/zettlr: Permission denied`.  `/opt/bin/zettlr` was the
correct `../zettlr/Zettlr` symlink and `/opt` was executable, but
`/opt/zettlr` was root-owned mode `0700`.  The cause was `cp -a .
"${ED}/opt/zettlr/"`: although `dodir` first made a suitable destination,
the archive-preserving copy applied the extracted AppImage root's mode to
that destination.

The exact upstream AppImages and pre-change install images were inspected
before the ebuild was edited:

| Host / architecture | Extracted AppImage directories | Pre-change install image |
|---|---:|---:|
| `gentoo` / arm64 | 35 directories, all `0700` | 9 directories under `/opt/zettlr`, all `0700` |
| `server01` / amd64 | 36 directories, all `0700` | 9 directories under `/opt/zettlr`, all `0700` |

This proved that correcting only `/opt/zettlr` would be insufficient.  The
ebuild now runs `find "${ED}/opt/zettlr" -type d -exec chmod 0755 {} + ||
die` immediately after the copy.  It does not alter regular-file modes.
The existing root ownership and mode `4711` handling for `chrome-sandbox`,
the PaX marking, and the launcher symlink are unchanged.

### Final build results

Both final tests used:

```text
ebuild app-text/zettlr-bin/zettlr-bin-4.7.0.ebuild clean unpack prepare configure compile install
```

They were run with root privileges only to create the Portage build and
install images; neither package was merged or installed.  `server01`
built from this repository checkout.  To avoid modifying the repository
checkout on `gentoo`, arm64 built from a temporary overlay copy at
`/tmp/codex/app-text/zettlr-bin-4.7.0/overlay`.

| Host | Architecture | Result | ASAR helper |
|---|---|---|---|
| `gentoo` | arm64 | exit 0; `>>> Completed installing` | 2 files / 9,296,470 bytes removed; 425 surviving files integrity-verified with SHA256; final ASAR 65,551,437 bytes |
| `server01` | amd64 | exit 0; `>>> Completed installing` | identical result, including 425 SHA256-verified survivors |

### Final install-image checks

The results were identical on both hosts unless stated otherwise:

- `/opt/zettlr`: `root:root`, mode `0755`.
- Every one of the 9 installed directories under and including
  `/opt/zettlr`: mode `0755`; the search for directories lacking ordinary
  user read/search permission produced no output.
- `/opt/zettlr/Zettlr`: `root:root`, mode `0755`.
- `/opt/zettlr/chrome-sandbox`: `root:root`, mode `4711`.
- `/opt/bin/zettlr`: `../zettlr/Zettlr`; resolving it inside each image
  reached that image's `/opt/zettlr/Zettlr`.
- `find <image> -xtype l -print` produced no output: no broken symlink was
  installed.
- Effective `L10N` was `en-US he ru` and effective package USE contained
  `l10n_en-US l10n_he l10n_ru` on both hosts.  The retained locale files
  were exactly `en-US.pak`, `he.pak`, and `ru.pak`.  This agrees with the
  current `chromium-2.eclass` contract: unselected language packs are
  removed and `en-US` is always retained.
- `scanelf -BF '%F' -R <image>` found 10 ELF files on each architecture:
  Zettlr, chrome-sandbox, chrome_crashpad_handler, pandoc, Nodehun.node,
  libEGL.so, libGLESv2.so, libffmpeg.so, libvk_swiftshader.so, and
  libvulkan.so.1.  Running `lddtree` over every result and searching its
  output for `not found` produced no output.

For the non-root smoke test, each image's `opt` directory was bind-mounted
over `/opt` inside a private mount namespace.  Zettlr was then run as UID
and GID 1000 with an image-specific writable temporary home, no display,
and a 10-second bound:

```text
/opt/bin/zettlr --version
Zettlr 4.7.0
```

The command exited 0 on both arm64 and amd64.  Thus execution passed the
shell's filesystem permission check and started the packaged executable;
there was no Electron display or sandbox error in this bounded path.
Interactive GUI startup, rendering, desktop integration, and prolonged
runtime behavior remain untested because no graphical session was used.

### Manifest and QA

Exact results in the edited repository on `server01`:

```text
$ pkgdev manifest app-text/zettlr-bin
manifests are up to date
pkgdev manifest exit 0

$ pkgcheck scan app-text/zettlr-bin
pkgcheck scan exit 0
```

The first sandboxed `pkgcheck` attempt could not write its cache and exited
2; it was repeated with normal access to the existing user cache, producing
the authoritative clean result above.  The Manifest did not change.
