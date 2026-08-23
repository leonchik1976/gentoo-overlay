# media-sound/lmms validation log

Concise, factual record of real build/install validation actually
performed for `media-sound/lmms` snapshots (this overlay never
runs `emerge`/`merge`/`qmerge` — validation stops at `ebuild ... install`,
per this repo's CLAUDE.md). Full raw build logs (~4900 lines each,
compiler output) were kept at `/tmp/claude/lmms-arm64-build.log` and
`/tmp/claude/lmms-amd64-build.log` on their respective hosts at the time
of this run; that location is ephemeral (`/tmp/claude`), so treat this
file as the durable record and re-run to regenerate raw logs if needed.

## 2026-08-23 — `1.3.0_pre20260823` snapshot validation

The snapshot at LMMS commit
`c6683775e57d9f9bce5871bb9e4c02413a98f88a` was built from the current
ebuild on both supported architectures.  Both commands stopped after
creating a binary package; neither package was merged or installed.

| | arm64 | amd64 |
|---|---|---|
| Host | `gentoo` | `server01` |
| Command | `sudo env PKGDIR=/tmp/codex/binpkgs ebuild media-sound/lmms/lmms-1.3.0_pre20260823.ebuild clean package` | `sudo env PKGDIR=/tmp/codex/media-sound/lmms-1.3.0_pre20260823/binpkgs ebuild media-sound/lmms/lmms-1.3.0_pre20260823.ebuild clean package`, from `/tmp/codex/media-sound/lmms-1.3.0_pre20260823/repo` |
| Result | exit 0; 916 compile steps; `>>> Completed installing`; `>>> Creating binpkg`; `>>> Done.` | exit 0; 924 compile steps; `>>> Completed installing`; `>>> Creating binpkg`; `>>> Done.` |
| Installed-image size | 40.7 MiB | 42.0 MiB |

The amd64 image included the Wine VST helper
`/usr/lib64/lmms/RemoteVstPlugin64.exe.so`; both images included the GIG
and STK plugins.  Tests were disabled by `RESTRICT=test`.  This entry
records build/install-image coverage only; GUI, audio/MIDI hardware, and
plugin runtime behavior were not exercised.

## 2026-08-21 — CMake 4 minimums and unused `CMAKE_C_FLAGS` notice

The arm64 build originally emitted three CMake QA notices: CMake 4 had
removed compatibility with the bundled ringbuffer minimum `2.8` and
game-music-emu minimum `2.6`, and the native VST bridge's nested CMake
configuration reported `CMAKE_C_FLAGS` as unused.

Exact pinned-source inspection found the minimums at
`src/3rdparty/ringbuffer/CMakeLists.txt` and
`plugins/FreeBoy/game-music-emu/CMakeLists.txt`.  Patch
`lmms-1.3.0-cmake-minimums.patch`, applied through the global `PATCHES`
array by the normal `cmake_src_prepare` call, raises both to 3.10.  CMake
4.3.4 configured and built the complete package successfully on both
architectures with those policy settings; no `CMAKE_POLICY_VERSION_MINIMUM`
or `CMAKE_QA_COMPAT_SKIP` workaround is used.

The unused-variable notice was investigated from the generated command,
not suppressed.  `cmake.eclass` automatically initializes top-level
`CMAKE_C_FLAGS` in `gentoo_toolchain.cmake`; LMMS's top-level
`project(lmms)` enables the default C and CXX languages and also reads
that variable in its own CMake files.  The actual notice instead came
from `NativeLinuxRemoteVstPlugin64.cmake`, whose `ExternalProject_Add`
explicitly supplied `-DCMAKE_C_FLAGS=-DNATIVE_LINUX_VST` to
`RemoteVstPlugin/CMakeLists.txt`.  That nested project declares only
`LANGUAGES CXX`, and its target consists solely of C++ sources; the same
definition was already in `CMAKE_CXX_FLAGS`.  The patch therefore removes
only the dead C-flags argument.  Enabling C would be semantically wrong,
and `CMAKE_WARN_UNUSED_CLI=no` was not retained because it would not fix
the nested invocation and would hide unrelated command-line mistakes.

### Upstream and Gentoo searches

- CMake 4.0 release documentation confirms removal of compatibility below
  3.5; current documentation also marks compatibility below 3.10 deprecated.
- LMMS issue https://github.com/LMMS/lmms/issues/7822 tracks CMake 4
  failures in bundled submodules.  Current LMMS still has a 3.13 top-level
  minimum.  Current ringbuffer has raised its minimum to 3.5; its issue and
  pull-request searches found no closer matching report.  Current
  game-music-emu uses `3.3...3.10`; issue
  https://github.com/libgme/game-music-emu/issues/128 and pull request
  https://github.com/libgme/game-music-emu/pull/92 are relevant prior work.
- Gentoo Bugzilla trackers https://bugs.gentoo.org/951350 (CMake 4
  breakage) and https://bugs.gentoo.org/964405 (future removal of
  compatibility below 3.10) were both `CONFIRMED`.  A Bugzilla REST
  quicksearch for `lmms cmake` returned no package-specific result; that
  statement is limited to this search.

### Final build/install-image validation

Both runs used CMake 4.3.4 and stopped at `ebuild ... install`; neither
image was merged or installed.

| | arm64 | amd64 |
|---|---|---|
| Host | `gentoo` | `server01` |
| Effective USE | `alsa arm64 carla elibc_glibc fluidsynth gig jack kernel_linux lv2 mp3 ogg portaudio pulseaudio sdl sid sndio soundio stk vst` | `abi_x86_64 alsa amd64 carla elibc_glibc fluidsynth gig jack kernel_linux lv2 mp3 ogg portaudio pulseaudio sdl sid sndio soundio stk vst` |
| Command | `USE="carla fluidsynth gig lv2 portaudio sid sndio soundio stk vst" ebuild media-sound/lmms/lmms-1.3.0_pre20260817.ebuild clean unpack prepare configure compile install` | same, from `/tmp/codex/media-sound/lmms-1.3.0_pre20260817/overlay`; no server01 repository file was changed |
| Raw log | `/tmp/codex/media-sound/lmms-1.3.0_pre20260817/gentoo-arm64-final-build.log` | `/tmp/codex/media-sound/lmms-1.3.0_pre20260817/server01-amd64-build.log` on `server01` |
| Phase result | exit 0; patch applied without fuzz; configure, compile and install-image completed | exit 0; patch applied without fuzz; configure, compile and install-image completed |
| Targeted notice scan | no compatibility, `CMAKE_C_FLAGS`, CMake policy, or severe QA notice | same |
| Image `lmms --version` | exit 0: `LMMS 1.3.0-alpha (Linux arm64, Qt 6.11.2, GCC 16.2.0)` | exit 0: `LMMS 1.3.0-alpha (Linux x86_64, Qt 6.11.2, GCC 16.2.0)` |
| Installed ELFs checked with image plugin path | 60; no unresolved libraries | 61; no unresolved libraries |
| Expected artifacts | GIG, STK, Carla, LV2, SID and native VST bridge files present | same; additionally the amd64 Wine VST helper was present |
| Zyn exclusions | `libzynaddsubfx.so`, `RemoteZynAddSubFx`, and `presets/ZynAddSubFX` all absent | same |

The builds still print pre-existing non-policy CMake warnings about Wine
layout detection, locale generation, and extra Qt paths passed to the
nested VST configure.  They do not reproduce the three notices addressed
here and did not generate a severe QA notice.  Runtime coverage remains
limited to the non-GUI `--version` check; no audio/MIDI hardware, GUI,
Wine-hosted plugin, Carla, GIG sample, LV2 host, or STK instrument session
was exercised.

`pkgdev manifest media-sound/lmms` printed exactly `manifests are up to
date` and exited 0.  `pkgcheck scan media-sound/lmms` exited 0 with exactly:

```text
media-sound/lmms
  NonsolvableDepsInDev: version 1.3.0_pre20260817: nonsolvable depset(depend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (18 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInDev: version 1.3.0_pre20260817: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (18 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInStable: version 1.3.0_pre20260817: nonsolvable depset(depend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (24 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInStable: version 1.3.0_pre20260817: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (24 total): solutions: [ media-libs/libgig, media-libs/stk ]
```

The Manifest did not change: this repository uses thin Manifests, so the
new local patch is not represented there.  The package is not
pkgcheck-clean because the four known keyword findings remain.

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
