# media-sound/lmms validation log

Concise, factual record of real build/install validation actually
performed for `media-sound/lmms-1.3.0_pre20260817` (this overlay never
runs `emerge`/`merge`/`qmerge` — validation stops at `ebuild ... install`,
per this repo's CLAUDE.md). Full raw build logs (~4900 lines each,
compiler output) were kept at `/tmp/claude/lmms-arm64-build.log` and
`/tmp/claude/lmms-amd64-build.log` on their respective hosts at the time
of this run; that location is ephemeral (`/tmp/claude`), so treat this
file as the durable record and re-run to regenerate raw logs if needed.

## 2026-08-21 — ZynAddSubFx excluded via PLUGIN_LIST, corrected LICENSE=, metadata.xml note

(This section originally also covered a `REQUIRED_USE="arm64? ( !gig
!stk )"` constraint, added and verified working here at the time. That
constraint has since been removed — see the dedicated `gig`/`stk` section
below for the current state and why.)

Both rows below are from builds run against the actual current ebuild
content (`PLUGIN_LIST` override + `src_install` preset cleanup included).
The amd64 row specifically replaces an earlier, now-stale log entry that
predated the `PLUGIN_LIST`/ZynAddSubFx-exclusion fix — that entry
described a build that no longer matches what the ebuild currently does.

| | arm64 | amd64 |
|---|---|---|
| Host | this host (native) | server01 (ssh) |
| Command | `ebuild lmms-1.3.0_pre20260817.ebuild clean unpack prepare configure compile install` | same, via ssh |
| PORTAGE_TMPDIR / PKGDIR / DISTDIR | `/tmp/claude/portage-{tmp,binpkgs,distfiles}` | same |
| **Effective USE** (`build-info/USE`, i.e. what was *actually* built and tested — the profile's own default IUSE resolution, no explicit override) | `alsa arm64 elibc_glibc jack kernel_linux mp3 ogg pulseaudio sdl` | `abi_x86_64 alsa amd64 elibc_glibc jack kernel_linux mp3 ogg pulseaudio sdl` |
| Result | exit 0, `>>> Completed installing` | exit 0, `>>> Completed installing` |
| `lmms --version` | `LMMS 1.3.0-alpha (Linux arm64, Qt 6.11.2, GCC 16.2.0)` | `LMMS 1.3.0-alpha (Linux x86_64, Qt 6.11.2, GCC 16.2.0)` |
| `ldd` unresolved libs | none | none |
| `merge`/`qmerge`/`emerge` run? | no | no |

### ZynAddSubFX exclusion — verified absent, all three installed paths, both arches

Checked directly against each build's installed image (`test -e`, not a
wildcard glob):

| Path | arm64 | amd64 |
|---|---|---|
| `/usr/lib64/lmms/libzynaddsubfx.so` (plugin) | absent | absent |
| `/usr/lib64/lmms/RemoteZynAddSubFx` (remote helper binary) | absent | absent |
| `/usr/share/lmms/presets/ZynAddSubFX` (preset data, removed in `src_install`) | absent | absent |

Note what this does and doesn't cover: `carla`, `fluidsynth`, `lv2`,
`portaudio`, `sid`, `sndio`, `soundio`, `test`, `vst` were all **off** in
both runs above (this profile's defaults) — those code paths were not
exercised by this specific build/install pass. `jack` was on in both
runs, so the `weakjack`/`jack2` submodule path did get real compile
coverage. `carla`/`sid` (and their submodule fetch/stub logic) have not
been build-tested with those flags enabled — only verified via static
CMakeLists.txt/source inspection (see `docs/lmms-license-audit.md`).
`gig`/`stk` **have** now been build-tested end-to-end — see the dedicated
section below; they were off (profile default) in the two runs described
in the table above.

`pkgdev manifest` / `pkgcheck scan --repo .` on both hosts (as of this
2026-08-21 entry): manifest up to date; pkgcheck reports exactly the four
documented, expected `NonsolvableDepsInDev`/`NonsolvableDepsInStable`
findings for `gig`/`stk` on arm64 (see `docs/lmms-license-audit.md` for
why — a real, independent `::gentoo` keyword gap, unrelated to anything
in this ebuild) — no other findings, on either host. Do not describe this
package as pkgcheck-clean; it consistently reports exactly these four
findings and none of the changes made this session have altered that.

### 2026-08-21 — real build with USE="gig stk" enabled (arm64)

`REQUIRED_USE="arm64? ( !gig !stk )"` (added in an earlier revision of
this ebuild and described in earlier versions of this log) has been
**removed**. The maintainer independently accepted `media-libs/libgig`'s
and `media-libs/stk`'s missing `::gentoo` keywords locally and confirmed
`libgig-4.4.1`/`stk-4.6.2` build and install; this section is the matching
real `media-sound/lmms` build with both flags enabled, run to confirm the
same works end-to-end for LMMS itself.

| | arm64 |
|---|---|
| Host | this host (native) |
| Date | 2026-08-21 |
| Command | `USE="gig stk" ebuild lmms-1.3.0_pre20260817.ebuild clean unpack prepare configure compile install` |
| PORTAGE_TMPDIR / PKGDIR / DISTDIR | `/tmp/claude/portage-{tmp,binpkgs,distfiles}` |
| Pre-existing system packages used (not installed by this session — already present from the maintainer's own prior action) | `media-libs/libgig-4.4.1`, `media-libs/stk-4.6.2` (confirmed via `qlist -Iv` before the build) |
| **Effective USE** (`build-info/USE`) | `alsa arm64 elibc_glibc gig jack kernel_linux mp3 ogg pulseaudio sdl stk` |
| CMake confirmation | `LMMS_HAVE_GIG='TRUE'`, `WANT_GIG='yes'`, `LMMS_HAVE_STK='TRUE'`, `WANT_STK='yes'` (from `lmms --version` build-options output) |
| Result | exit 0, `>>> Completed installing` (raw log: `/tmp/claude/lmms-arm64-gigstk-build.log`) |
| GIG plugin path | `/usr/lib64/lmms/libgigplayer.so` — present |
| STK plugin path | `/usr/lib64/lmms/libmalletsstk.so` — present |
| `lmms --version` | `LMMS 1.3.0-alpha (Linux arm64, Qt 6.11.2, GCC 16.2.0)` |
| `ldd` unresolved libs, all installed `.so`/binaries including the two new plugins specifically | none |
| ZynAddSubFx paths (should remain absent — unrelated exclusion preserved) | `libzynaddsubfx.so`, `RemoteZynAddSubFx`, `presets/ZynAddSubFX` — all still absent |
| `merge`/`qmerge`/`emerge` run? | no — build/install phases only, into an isolated image dir, never merged to the live system |

Not build-tested this session: `USE="gig stk"` on amd64 (not requested;
`libgig`/`stk` are already keyworded `amd64` in `::gentoo` so no
local-keyword-acceptance question applies there in the first place).

## Earlier runs this session

Two earlier full build+install passes (before the `REQUIRED_USE`/license
corrections above) also succeeded on both arches, plus one prior pass that
surfaced a real `docompress`/pre-compressed-manpage QA notice (fixed via
`docompress -x /usr/share/man` in `src_install`, re-verified clean on a
subsequent run). Superseded by the 2026-08-21 final-ebuild run above;
recorded here only for continuity, not as a separate current claim.
