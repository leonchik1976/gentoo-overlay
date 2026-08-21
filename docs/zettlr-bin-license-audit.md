# app-text/zettlr-bin-4.7.0 license audit

Full findings from the 2026-08-21 audit (re-verified with a second, deeper
pass the same day) against the real v4.7.0 AppImage (extracted via
`--appimage-extract`, plus `asar extract` on the embedded
`resources/app.asar`). Referenced from a short comment in the ebuild; kept
here instead of inline so the ebuild body stays short.

- **Zettlr's own code**: `app.asar`'s `package.json` declares `"license":
  "GPL-3.0"` (no "or later" grant) -> `GPL-3`. Note the AppImage's
  top-level `./LICENSE` file is NOT Zettlr's license — it's Electron's own
  MIT license text (electron-builder ships it at that path by default).
- **Electron/Chromium runtime + bundled npm deps** (`.webpack/main` and
  `.webpack/renderer/*/index.js.LICENSE.txt`, webpack's standard
  license-comment extraction): `MIT` (Electron itself, pinia, Vue 3,
  Sindre Sorhus packages, ...) and `BSD-3-Clause` (Google-authored files,
  per their SPDX-License-Identifier headers) -> `MIT` + `BSD`.
  DOMPurify 3.4.12's own build-banner comment reads "Released under the
  Apache license 2.0 and Mozilla Public License 2.0", but that wording is
  just informal banner text; its actual `package.json`/`LICENSE` metadata
  (github.com/cure53/DOMPurify) states `"license": "(MPL-2.0 OR
  Apache-2.0)"` — a real either/or choice, not a conjunctive requirement.
  Since `MPL-2.0` is already unconditionally required (fr-FR dictionary,
  below), the MPL-2.0 branch of that choice is already satisfied, so
  `Apache-2.0` is not listed separately — it would be redundant.
- **resources/pandoc**: a bundled, statically-linked, unmodified upstream
  Pandoc binary (`strings` shows "Copyright (C) 2006-2025 John
  MacFarlane"; no `COPYING` file ships alongside the binary in this
  distfile, so cross-checked against jgm/pandoc's own `COPYRIGHT` file) ->
  `GPL-2+`.
- **`.webpack/main/dict/*/LICENSE`** (bundled Hunspell spellcheck
  dictionaries):
  - en-US, en-GB (SCOWL/Kevin Atkinson): the actual grant text
    ("Permission to use, copy, modify, distribute and sell ... for any
    purpose is hereby granted without fee, provided that the above
    copyright notice appears in all copies ...") matches Gentoo's `ISC`
    license file, not `BSD` — it lacks BSD's redistribution-conditions
    structure and instead matches ISC's "for any purpose ... provided
    notice appears in all copies" phrasing almost verbatim. The same file
    separately credits the affix file as "a heavily modified version of
    ... Ispell ... covered by his BSD license", and separately places
    portions (the Moby/MWords list, the UK frequency wordlist) in the
    public domain (no `LICENSE=` entry needed for public domain content)
    -> `ISC` (+ `BSD`, already listed for other reasons).
  - ru-RU (Alexander I. Lebedev): a BSD-family grant (retain/reproduce
    notice, no endorsement, plus an extra "modified versions must be
    marked" clause with no exact stock match) -> approximated as `BSD`.
  - nl-NL (OpenTaal): explicitly offers "at the discretion of the user"
    either (A) BSD 3-Clause License or (B) CC-BY-4.0; BSD 3-Clause here
    is a verbatim match for Gentoo's plain `BSD` file -> `BSD` (already
    satisfies the choice, CC-BY-4.0 not needed).
  - de-DE (igerman98): "GNU General Public License version 2 or 3" — the
    user's real, explicit choice between exactly GPL-2 or GPL-3 (not "2
    or later") -> already satisfied by the unconditional `GPL-3` above.
  - uk-UK (spell-uk): "GPL 2.0 or above, LGPL 2.1 or above and MPL
    (Mozilla Public License) 1.1 licenses" — standard Hunspell
    triple-license boilerplate, meaning the user may pick any one of the
    three (this exact phrasing is reused verbatim across many unrelated
    Hunspell dictionaries as a triple-OR grant, not a conjunctive AND) ->
    already satisfied by the unconditional `GPL-2+` above (from pandoc).
  - fr-FR (Dicollecte): plain, single "MPL version 2.0", no alternative
    -> already listed, unconditional.
  - es-ES: explicitly disjunctive — "se distribuye bajo un triple esquema
    de licencias disjuntas: GNU GPL versión 3 o posterior, GNU LGPL
    versión 3 o posterior, ó MPL versión 1.1 o posterior. Puede
    seleccionar libremente ..." ("may freely choose") -> already
    satisfied by the unconditional `GPL-3` above.
  - **tr-TR**: ships no LICENSE/COPYING/NOTICE file in this distfile
    (just `.aff`/`.dic`). Checked upstream Zettlr's own
    `static/dict/tr-TR/` (same gap), its full git history for that path
    (only a 2021 file-move commit, no origin/attribution info), and the
    `.aff` file's own header (no author/license comment) — genuinely
    unresolvable from available evidence. **Removed from the packaged
    `resources/app.asar` at build time** (2026-08-21) via
    `files/asar-strip-dict.py`, a self-contained, stdlib-only Python
    script run from `src_prepare()` — see "tr-TR removal" below for how
    this was verified safe.

Resulting `LICENSE="GPL-3 GPL-2+ MIT BSD MPL-2.0 ISC"`.

## tr-TR removal — how it was verified safe (2026-08-21)

An earlier pass left tr-TR shipped with its licensing gap documented,
reasoning that removing it needed an `asar` CLI tool this overlay doesn't
package, and `npx asar` would need network access during the ebuild phase
(forbidden by this repo's CLAUDE.md). Revisited: the asar format itself is
a simple, fully documented Chromium "Pickle" binary format wrapping a JSON
directory header, parseable and rewritable with nothing but Python's
stdlib (`struct`, `json`) — no node/npm/network required. `files/asar-strip-dict.py`
implements this directly.

Verified two things before wiring it into `src_prepare()`:

1. **Structural correctness**: parsed both the original and the
   tr-TR-stripped `app.asar` independently, then compared all 426
   surviving file entries between them — same sizes, byte-for-byte
   identical content, zero new/missing entries beyond the intended 2
   removed files (`dict/tr-TR/tr-TR.aff`, `dict/tr-TR/tr-TR.dic`).
2. **Integrity-check safety**: extracted the real Electron `asar-fs-wrapper`
   JS embedded in the `Zettlr` binary itself (via `strings`) and read its
   actual `validateBufferIntegrity()` logic — it hashes a file's freshly-read
   bytes and compares against that *same file's own* `integrity.hash`
   field stored in the *same* asar's header (a self-consistency check, not
   a cross-reference to an externally-stored, tamper-evident value).
   Additionally searched the entire extracted AppImage tree for Electron's
   "fuse wire" sentinel string (`dL7pKGdnNz796PbbjQWNKmHXBZaB7jAZ`, used by
   the `EmbeddedAsarIntegrityValidation` fuse to burn an expected
   header hash into the binary) — not found anywhere, meaning this
   specific Electron build has no active external-hash validation to
   defeat. Combined with (1) confirming every surviving file's content
   still matches its own stored SHA256 integrity hash exactly (recomputed
   directly, not assumed), a rewritten asar missing only the tr-TR entries
   passes Electron's own real validation logic.

Three other bundled files also matched `tr-TR` in a path search and were
correctly left untouched, since they're unrelated to the Hunspell
dictionary licensing question: `assets/csl-locales/locales-tr-TR.xml`
(citation-style-language locale data) and `lang/tr-TR.po` (Zettlr's own
first-party Turkish UI translation, covered by Zettlr's own GPL-3 grant).

Independently re-verified 2026-08-21 (separate from the work above): a
fresh `ebuild clean unpack prepare configure compile install` run against
the real distfile confirmed the script runs cleanly in-phase (log:
`removed 2 file(s) (9296470 bytes) under /.webpack/main/dict/tr-TR`), the
full install completes, and the stripped `resources/app.asar` is
9,297,134 bytes smaller than the unstripped original (2 files' raw content
plus a small header-shrinkage delta from removing their directory
entries) — consistent with exactly the intended removal and nothing else.

Not done: launching the real packaged `Zettlr` binary against the
modified asar for an end-to-end GUI confirmation. An attempt to do so via
`ELECTRON_RUN_AS_NODE=1` unexpectedly launched the full application
instead of running a diagnostic script, writing real first-run state to
`~/.config/Zettlr/` on this host (cleaned up immediately, no user data
existed there before or was lost). Given the risk of further unintended
side effects and that the static/hash-based verification above is already
strong evidence, this was not repeated. If you want an actual GUI
smoke-test of the modified package, that's still worth doing separately
before relying on this in day-to-day use.

### Hardening pass (2026-08-21)

The verification described above (structural comparison, integrity-hash
recomputation) was originally a one-off manual check done *before* wiring
the script into `src_prepare()` — real evidence, but not something later
runs automatically re-confirm. `files/asar-strip-dict.py` was hardened so
every invocation carries its own proof, not just the first one:

- **Format cross-validation**: all four redundant size fields in the asar
  header (outer/inner pickle sizes, header size, JSON length) are now
  checked against each other and against the actual file size before
  anything else runs; a malformed or unexpected-format archive fails
  loudly instead of silently producing a corrupt rewrite.
- **Per-file cryptographic integrity verification, built into every run**:
  each surviving file's bytes are hashed (SHA256, whole-file and
  per-block, matching Electron's own `blockSize`/`blocks` granularity) and
  compared against that file's own stored `integrity` block *before* being
  carried into the rewritten archive — the same check Electron's
  `asar-fs-wrapper` performs at load time, not a separate one-off script.
  Re-run against the real v4.7.0 asar: `425 surviving file(s)
  integrity-verified (SHA256)`, matching the original one-off check's
  finding exactly.
- **Bounds-checked reads**: an entry claiming an offset/size that would
  run past the source file's actual length is now a hard error instead of
  a silently truncated/wrong Python slice.
- **Path-traversal guard** on the dict-name argument.
- **Atomic write**: writes to a temp file in the same directory and
  `os.replace()`s it into place, so a crash or disk-full mid-write can't
  leave a half-written, corrupt asar in place.
- **Self-check before disk**: the rewritten archive is re-parsed and its
  own header re-validated before the real file is ever touched.

What this still does *not*, and cannot, prove: that the archive as a
whole matches some externally-stored, tamper-evident value. This specific
Electron build has no such check to defeat (no
`EmbeddedAsarIntegrityValidation` fuse-wire sentinel found in the packaged
binary, per the investigation above) — there is nothing further to verify
against. The per-file SHA256 checks confirm the bytes are exactly what
Electron's own asar-fs-wrapper would accept as valid for each surviving
file; they don't constitute an end-to-end GUI smoke-test (still not done,
per above).
