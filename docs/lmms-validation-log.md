# media-sound/lmms validation log

Concise, factual record of real build/install validation actually
performed for `media-sound/lmms-1.3.0_pre20260817` (this overlay never
runs `emerge`/`merge`/`qmerge` — validation stops at `ebuild ... install`,
per this repo's CLAUDE.md). Full raw build logs (~4900 lines each,
compiler output) were kept at `/tmp/claude/lmms-arm64-build.log` and
`/tmp/claude/lmms-amd64-build.log` on their respective hosts at the time
of this run; that location is ephemeral (`/tmp/claude`), so treat this
file as the durable record and re-run to regenerate raw logs if needed.

## 2026-08-21 — final ebuild (ZynAddSubFx excluded via PLUGIN_LIST, REQUIRED_USE, corrected LICENSE=, metadata.xml note)

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

Note what this does and doesn't cover: `carla`, `fluidsynth`, `gig`,
`lv2`, `portaudio`, `sid`, `sndio`, `soundio`, `stk`, `test`, `vst` were
all **off** in both runs above (this profile's defaults) — those code
paths were not exercised by this specific build/install pass. The
`REQUIRED_USE="arm64? ( !gig !stk )"` verification (separate section
below) specifically exercised `gig`/`stk` via `emerge --pretend`, but that
was a dependency-resolution check only, not a compile; neither `gig` nor
`stk` has been build-tested end-to-end this session. `jack` was on in
both runs, so the `weakjack`/`jack2` submodule path did get real compile
coverage. `carla`/`sid` (and their submodule fetch/stub logic) have not
been build-tested with those flags enabled either — only verified via
static CMakeLists.txt/source inspection (see
`docs/lmms-license-audit.md`).

`pkgdev manifest` / `pkgcheck scan --repo .` on both hosts: manifest up to
date; pkgcheck reports exactly the four documented, expected
`NonsolvableDepsInDev`/`NonsolvableDepsInStable` findings for the
off-by-default `gig`/`stk` flags on arm64 (see
`docs/lmms-license-audit.md`) — no other findings, on either host.

`REQUIRED_USE="arm64? ( !gig !stk )"` was additionally verified with real
`emerge --pretend --oneshot media-sound/lmms` runs under an isolated
`PORTAGE_CONFIGROOT` (not the live system's `/etc/portage`) on both hosts:
rejected with an explicit `REQUIRED_USE flag constraints are unsatisfied`
error on arm64 with `USE="gig stk"` forced; resolved normally with
`USE="gig stk"` on amd64. No package was merged in either case
(`--pretend` only).

## Earlier runs this session

Two earlier full build+install passes (before the `REQUIRED_USE`/license
corrections above) also succeeded on both arches, plus one prior pass that
surfaced a real `docompress`/pre-compressed-manpage QA notice (fixed via
`docompress -x /usr/share/man` in `src_install`, re-verified clean on a
subsequent run). Superseded by the 2026-08-21 final-ebuild run above;
recorded here only for continuity, not as a separate current claim.
