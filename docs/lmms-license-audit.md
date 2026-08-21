# media-sound/lmms-1.3.0_pre20260817 license audit

Full bundled-source audit against the pinned commits in the ebuild
(`MY_COMMIT` and the per-submodule `*_COMMIT` variables), performed
2026-08-21, corrected 2026-08-21 (ZynAddSubFX license authority), and
corrected again 2026-08-21 (real linkage finding — see "ZynAddSubFX
licensing" below). Referenced from a short comment in the ebuild; kept
here instead of inline so the ebuild body stays short.

| Component | Path | License | Evidence |
|---|---|---|---|
| LMMS core | (main tree) | GPL-2+ | `src/core/main.cpp`: "version 2 of the License, or (at your option) any later version" |
| game-music-emu | plugins/FreeBoy | LGPL-2.1 | `license.txt`; no "or later" grant found in any checked source header |
| adplug | plugins/OpulenZ | LGPL-2.1+ | `src/adplug.h` states "or later" |
| exprtk | plugins/Xpressive | MIT | `license.txt` |
| ~~zynaddsubfx~~ | ~~plugins/ZynAddSubFx~~ | excluded from build | See "ZynAddSubFX licensing" below — real GPL-2-only/GPL-3+ conflict, resolved by dropping the plugin |
| portsmf | plugins/MidiImport | MIT/Expat | `license.txt`; Debian's lmms copyright file independently confirms "License: Expat" for this path |
| hiir | src/3rdparty/hiir | WTFPL | its own `license.txt` is the Sam Hocevar v2 text; this overlay's `licenses/WTFPL` was written from that exact text (GURU's own `licenses/WTFPL` is a different, older v1.0 text and would not have matched) |
| ringbuffer | src/3rdparty/ringbuffer | GPL-3+ | `include/ringbuffer/ringbuffer.h`: "version 3 of the License, or (at your option) any later version"; **real compiled code** (`src/lib/ringbuffer.cpp`, confirmed in the actual submodule tarball — not header-only), statically linked into LMMS's own core objects (`target_static_libraries(lmmsobjs ringbuffer)` in `src/CMakeLists.txt`, which feeds into the `lmms` executable target) and directly compiled into the always-built Vectorscope/Oscilloscope/SpectrumAnalyzer plugins via `include/LocklessRingBuffer.h` |
| carla (USE=carla) | plugins/CarlaBase/carla | GPL-2+ | only header directories are added to the include path for LMMS's own `Carla.cpp` (`plugins/CarlaBase/CMakeLists.txt`); none of carla's own `.cpp` files are compiled, so carla's huge third-party bundle (VST3 SDK, JUCE, etc.) never enters the build. Already covered by the unconditional GPL-2+ above |
| resid (USE=sid) | plugins/Sid/resid/resid | GPL-2+ | `sid.cc`; already covered |
| weakjack (USE=jack) | src/3rdparty/weakjack | GPL-2+ | `weak_libjack.c`; already covered |
| jack2 (USE=jack) | src/3rdparty/jack2 | LGPL-2.1+ | header-only here (`target_include_directories(jack_headers INTERFACE jack2/common)`, no jack2 `.cpp` compiled); `JackConstants.h`; already covered by adplug's unconditional LGPL-2.1+ |

Resulting `LICENSE="GPL-2+ LGPL-2.1 LGPL-2.1+ MIT WTFPL GPL-3+"` (no plain
`GPL-2` entry — it was only ever needed for zynaddsubfx, which is now
excluded). No USE-conditional `LICENSE=` gating is needed — every
USE-only license is a subset of the unconditional set.

## ZynAddSubFX licensing — corrected twice (2026-08-21)

**First correction**: an earlier pass treated ZynAddSubFX as GPL-2+ on the
authority of Debian's own `lmms` copyright file ("Despite the original
files stating GPL-2, ZynAddSubFX is under GPL-2+"). That's a third
party's assertion, not copyright-holder authority. Direct evidence from
the actual pinned distfile
(`zynaddsubfx-66a42efcc72d4d75a70412795f1510c4297ab826`) says the
opposite: `README.txt` states *"ZynAddSubFx is ... licensed under GNU
General Public License version 2 (and only version 2) - see the file
COPYING"*, `COPYING` is the plain unmodified GPL-2 text with no "or
later" clause, and individual source headers (`globals.h`, `Effect.h`,
`SynthNote.h`, `FFTwrapper.h`) all say plain "version 2". No
copyright-holder authority for "GPL-2+" exists.

**Second correction**: having established ZynAddSubFX is GPL-2-only, the
next question was whether that actually conflicts with anything. The
first attempt at answering this concluded "no conflict", based on
`ZynAddSubFxCore`'s own `target_link_libraries` (only
FFTW3F/Qt/Zlib/Threads) and zynaddsubfx's own sources never mentioning
`ringbuffer`. That check only covered the *inner* static-library target
(`plugins/ZynAddSubFx/CMakeLists.txt` line 120,
`add_library(ZynAddSubFxCore STATIC ...)`) and missed the *outer* one.
Every LMMS plugin, including zynaddsubfx, is actually built via the
`BUILD_PLUGIN` macro (`cmake/modules/BuildPlugin.cmake`, invoked at
`plugins/ZynAddSubFx/CMakeLists.txt:148`), which unconditionally does:

```cmake
ADD_LIBRARY(${PLUGIN_NAME} ${PLUGIN_LINK} ${PLUGIN_SOURCES} ${plugin_MOC_out} ${RCC_OUT})
target_link_libraries("${PLUGIN_NAME}" lmms Qt${QT_VERSION_MAJOR}::Widgets Qt${QT_VERSION_MAJOR}::Xml)
```

`lmms` here is the main executable target
(`ADD_EXECUTABLE(lmms ...)` at `src/CMakeLists.txt:114`, with
`ENABLE_EXPORTS ON` set at line 203 — confirmed directly in the source),
which the GPL-3+ vendored `ringbuffer` gets statically linked into via
`target_static_libraries(lmmsobjs ringbuffer)`. Also confirmed
`ringbuffer` is **not** header-only: the actual submodule tarball ships
`src/lib/ringbuffer.cpp`, real compiled object code, not just templates
in `include/ringbuffer/ringbuffer.h`.

So every plugin — including zynaddsubfx — links against an executable
that contains real compiled GPL-3+ code, via the same-process,
same-address-space, ABI-level symbol-resolution mechanism that
`ENABLE_EXPORTS` + `target_link_libraries(plugin lmms)` sets up (a
MODULE-type plugin resolving undefined symbols against the host
executable's exported table at `dlopen()` time). This is a materially
different, much tighter coupling than the out-of-process, no-shared-code
model used for Wine-hosted proprietary VST bridging, which was the wrong
comparison drawn in the first pass. This is a real GPL-2-only/GPL-3+
combination conflict, not a false alarm — `readelf -d` on the actually
*built* `libzynaddsubfx.so` doesn't show a `NEEDED` entry for `lmms`
(symbol resolution against an `ENABLE_EXPORTS` executable isn't recorded
that way), which is exactly why the first-pass check using only static
inspection of `target_link_libraries` calls and a source grep missed it —
the real coupling happens through the `BUILD_PLUGIN` macro's own
unconditional link line, not anything visible in the plugin's final
`.so`'s dynamic section.

### Resolution

Rather than replacing `ringbuffer` (used by multiple always-built core
plugins — Vectorscope, Oscilloscope, SpectrumAnalyzer — which would need
non-trivial upstream source patching to swap out, and would still leave
the `lmms` executable target itself containing GPL-3+ code that every
*other* plugin also links against), the ZynAddSubFx plugin itself is
excluded from the build entirely, via an explicit `PLUGIN_LIST` CMake
override in `src_configure` (the full `LMMS_PLUGIN_LIST` from
`cmake/modules/PluginList.cmake`, minus `ZynAddSubFx`).

Verified with a real build (arm64, this host): `libzynaddsubfx.so` and
`RemoteZynAddSubFx` no longer appear anywhere in the installed tree;
`lmms --version` still runs correctly; `ldd` shows no unresolved
libraries. The now-orphaned `/usr/share/lmms/presets/ZynAddSubFX` preset
data (7.7MB, not code, no licensing issue of its own, just dead weight
for an excluded plugin) is removed in `src_install`.

## gig / stk on arm64

`media-libs/libgig` and `media-libs/stk` (behind the off-by-default `gig`
and `stk` USE flags) both lack any `arm64` keyword in `::gentoo` (verified
2026-08-21: `KEYWORDS="amd64 ~ppc ~x86"` and similar — no `arm64` at all,
not even `~arm64`).

**2026-08-21 update**: an earlier revision of this ebuild carried
`REQUIRED_USE="arm64? ( !gig !stk )"`, added and verified (via
`emerge --pretend` under an isolated `PORTAGE_CONFIGROOT`) to actively
reject `USE="gig stk"` on arm64 with an explicit error. That constraint
has since been **removed**: the maintainer independently built
`media-libs/libgig-4.4.1` and `media-libs/stk-4.6.2` on arm64 after
locally accepting their missing keywords, and confirmed a full
`media-sound/lmms` build with `USE="gig stk"` enabled succeeds end-to-end
on arm64 (real build+install, both plugins present, `lmms --version`
runs, no unresolved libraries — see `docs/lmms-validation-log.md` for the
exact run). `gig`/`stk` have therefore been build-tested successfully on
arm64 by this ebuild; a user enabling either just needs to accept
`libgig`'s/`stk`'s
missing `::gentoo` keywords themselves first (e.g. via
`package.accept_keywords`), the same as for any other not-yet-keyworded
dependency — this is normal Portage usage, not a defect or an
unsupported configuration.

`pkgcheck scan` still reports four `NonsolvableDepsInDev`/
`NonsolvableDepsInStable` findings for this exact combination (checked
2026-08-21, after removing `REQUIRED_USE`) — these are unrelated to
`REQUIRED_USE` (which pkgcheck's dependency-solvability check never
factored in regardless, confirmed in earlier testing) and simply reflect
that `::gentoo`'s own tree hasn't keyworded `libgig`/`stk` on arm64 yet.
This is expected and does not indicate a problem with the ebuild; treat
`pkgcheck scan` output for this package as "four known findings", not
"clean".
