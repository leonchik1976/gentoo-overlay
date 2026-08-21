# games-emulation/dbgl-bin-0.99 license and dependency audit

Full findings from the 2026-08-21 audit against the real `dbgl099.tar.xz`
distfile. Referenced from a short comment in the ebuild; kept here instead
of inline so the ebuild body stays short.

## Bundled licenses

- **dbgl.jar itself**: the bundled `COPYING` is the unmodified FSF GPL-2
  text with no "or later" grant found anywhere in the distfile, and
  dbgl.org links to plain `gpl.html`; a public GitHub mirror
  (javiermisol/DBGL) likewise tags it plain GPL-2.0. Corrected from a
  previous unverified `GPL-2+` assumption to plain `GPL-2`.
- **lib/swtlin64.jar** (SWT native binding): bundled `about.html` states
  "Eclipse Public License Version 2.0" -> `EPL-2.0`. Note: `::gentoo`'s own
  `dev-java/swt` ebuilds declare CPL-1.0/LGPL-2.1/MPL-1.1 for older SWT
  releases predating Eclipse's 2005 CPL->EPL switch; this bundle is a 2024
  build and its own `about.html` overrides that as evidence. The
  `about_files/` LGPL-2.1/MPL-1.1/MPL-2.0/webkit-BSD texts describe the
  *system* GTK/WebKitGTK libraries SWT links against at runtime, not code
  shipped inside this jar, so they aren't added to `LICENSE=`.
- **lib/gallery-2.3.0.jar** (org.eclipse.nebula.widgets.gallery):
  Eclipse Foundation-signed jar (`META-INF/ECLIPSE_.SF` + `.RSA`), built
  Dec 2019, post-dating Eclipse's project-wide move to EPL-2.0 ->
  `EPL-2.0`. No `LICENSE` file is bundled directly in this jar to cite
  verbatim.
- **lib/jersey-2.45.jar**: `META-INF/NOTICE.md` states
  `SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0`
  (dual-licensed); `EPL-2.0` alone satisfies this.
- **lib/hsqldb-2.7.3.jar**: no license file bundled in the jar; upstream's
  custom BSD-style HSQLDB License has no matching file in `::gentoo`'s
  `licenses/`, so it's mirrored into this overlay's `licenses/HSQLDB`
  (matching this repo's existing convention for non-stock licenses, e.g.
  `licenses/GPL-2-with-Universal-FOSS-exception`). That file was
  originally transcribed from the hsqldb.org website page
  (hsqldb.org/web/hsqlLicense.html) and had one real wording discrepancy
  as a result: "Copyright (c) 1995-2000 by the Hypersonic SQL Group."
  instead of the authoritative distribution's "Copyright (c) 1995-2000,
  The Hypersonic SQL Group." Corrected 2026-08-21 by fetching the actual
  `hsqldb-2.7.3.zip` release archive
  (sourceforge.net/projects/hsqldb/files/hsqldb/hsqldb_2_7/hsqldb-2.7.3.zip/)
  and copying `hsqldb/doc/hypersonic_lic.txt` verbatim (the combined
  HSQL-Development-Group + Hypersonic-SQL-Group grant, exactly as bundled
  in the real distribution, diffed line-by-line against the website
  version to confirm this was the only substantive difference).

  Re-verified 2026-08-21 with a byte-level `diff` between `licenses/HSQLDB`
  and the source file directly (not just eyeballed): the only differences
  found were (1) `hypersonic_lic.txt` uses CRLF line endings, normalized to
  LF here to match every other file in this overlay's `licenses/`
  directory, and (2) the C-comment wrapper (`/* ... */`) the source file
  uses around the license text, stripped since this is a plain-text
  license file, not a source header. With those two purely
  formatting-level differences accounted for, the actual license
  text — every word, copyright line, and clause — is a character-for-
  character match.
- **lib/json-20240303.jar** (org.json/JSON-java): matches Gentoo's stock
  `JSON` license file byte-for-byte (diffed against `dev-java/json`'s own
  use of `LICENSE="JSON"` in `::gentoo`).
- **lib/commons-io-2.17.0.jar, lib/commons-lang3-3.17.0.jar,
  lib/commons-text-1.12.0.jar**: standard bundled `Apache-2.0`
  `META-INF/LICENSE.txt` + `NOTICE.txt` (Apache Commons).

Resulting `LICENSE="GPL-2 EPL-2.0 HSQLDB JSON Apache-2.0"`.

## GUI runtime dependencies

Verified 2026-08-21 via `readelf -d` against the bundled SWT native
bindings extracted from `lib/swtlin64.jar`: `libswt-pi3-gtk` (core GTK3
binding), `libswt-cairo-gtk`, and `libswt-atk-gtk` are loaded
unconditionally by SWT's `Display` bootstrap, giving `NEEDED` entries for
`libgtk-3.so.0`/`libgdk-3.so.0` (`x11-libs/gtk+:3`), `libcairo.so.2`
(`x11-libs/cairo`), `libatk-1.0.so.0` (`app-accessibility/at-spi2-core`),
and `libgio`/`libgobject`/`libglib-2.0` (`dev-libs/glib:2`). All four were
added to `RDEPEND` (previously missing entirely, despite the bundle
requiring a full SWT/GTK3 stack to run).

The bundle also ships optional `libswt-glx-gtk` (OpenGL canvas),
`libswt-webkit-gtk` (embedded browser) and `libswt-awt-gtk` (AWT bridge)
native libs; these are loaded only if DBGL actually exercises those
specific SWT APIs, which wasn't verified, so their extra deps
(`virtual/opengl`, `virtual/glu`, `net-libs/webkit-gtk`) are deliberately
not added.

The `SWT_GTK3=0` launcher environment variable present in an earlier
version of this ebuild was removed 2026-08-21: `lib/swtlin64.jar` only
ships the "pi3" (GTK3) native binding — no GTK2 alternative exists for
that variable to select — so it was dead configuration with no effect.
