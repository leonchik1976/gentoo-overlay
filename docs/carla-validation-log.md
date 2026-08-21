# media-sound/carla validation log

Concise, factual record of real build/install validation actually
performed for `media-sound/carla-2.5.10` (this overlay never runs
`emerge`/`merge`/`qmerge` — validation stops at `ebuild ... install`, per
this repo's CLAUDE.md). Full raw build logs were kept at
`/tmp/claude/carla-arm64-build.log` and `/tmp/claude/carla-amd64-build.log`
on their respective hosts at the time of this run; that location is
ephemeral, so treat this file as the durable record.

## 2026-08-21 — final ebuild (Python-compat confirmed, dead cleanup removed)

| | arm64 | amd64 |
|---|---|---|
| Host | this host (native) | server01 (ssh) |
| Command | `ebuild carla-2.5.10.ebuild clean unpack prepare configure compile install` | same, via ssh |
| **Effective USE** (`build-info/USE`, profile defaults, no override) | `X alsa arm64 elibc_glibc jack kernel_linux pulseaudio python_single_target_python3_14 sdl sndfile` | `X abi_x86_64 alsa amd64 elibc_glibc jack kernel_linux pulseaudio python_single_target_python3_14 sdl sndfile` |
| Result | exit 0, `>>> Completed installing` | exit 0, `>>> Completed installing` |
| `carla-discovery-native` | runs, prints usage | runs, prints usage |
| `ldd` unresolved libs | none | none |
| `merge`/`qmerge`/`emerge` run? | no | no |

Note: `fluidsynth` and `osc` were **off** in both runs (this profile's
defaults) — those code paths were not exercised.

`pkgdev manifest` / `pkgcheck scan --repo .` on both hosts: manifest up to
date, zero findings. One pre-existing upstream QA warning noted in earlier
runs (strict-aliasing in vendored `thirdparty/WDL/source/WDL/eel2/glue_port.h`)
— third-party vendored code, not something to fix in the ebuild.
