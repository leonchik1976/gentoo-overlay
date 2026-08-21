# media-sound/carla validation log

Factual record of build/install-image validation for
`media-sound/carla-2.5.10`.  No `emerge`, merge, install, or `qmerge` was
performed on either host.

## 2026-08-21 — broken headless `carla-single` launcher

### Multilib defect and source inspection

The installed launcher previously failed with:

```
Carla library folder does not exist, is Carla installed?
```

Inspection of the exact release `data/carla-single` found:

```python
INSTALL_PREFIX = "X-PREFIX-X"
CARLA_LIBDIR = os.path.join(INSTALL_PREFIX, "lib", "carla")
CARLA_RESDIR = os.path.join(INSTALL_PREFIX, "share", "carla", "resources")
```

Upstream `Makefile` defaults `LIBDIR := $(PREFIX)/lib`, installs the launcher
from `data/carla-single`, and substitutes only `X-PREFIX-X` in that file.
The ebuild's `LIBDIR="/usr/$(get_libdir)"` argument controls the installed
binaries and pkg-config files, but does not propagate into this Python
launcher.  Consequently, the original launcher searched `/usr/lib/carla`
while both tested systems installed Carla under `/usr/lib64/carla`.

The first correction tested in this investigation used `src_prepare` to
check and rewrite the exact shebang and `CARLA_LIBDIR` lines, selecting the
configured Python and `/usr/$(get_libdir)/carla`.  This was an intermediate
test only; the final ebuild no longer rewrites a launcher that it removes.

### Corrected-launcher test and removal decision

An arm64 install-image build was first performed with the corrected launcher
retained.  The installed file contained:

```python
#!/usr/bin/python3.14
INSTALL_PREFIX = "/usr"
CARLA_LIBDIR = "/usr/lib64/carla"
```

Running that install-image launcher with no arguments printed usage and
exited 0.  `/usr/lib64/carla` and executable
`/usr/lib64/carla/carla-bridge-native` were present in the image.

However, `/usr/share/carla/resources` was absent.  Inspection of upstream's
install rules established that the resource binaries are installed only
inside the `HAVE_PYQT=true` block; this ebuild deliberately builds with
`HAVE_PYQT=false`.  A bounded, network-isolated bubblewrap test exposed the
install-image `/usr/lib64/carla` at its final absolute path and hid all
live-system Carla resources:

```
timeout --signal=TERM --kill-after=2s 10s bwrap --unshare-net \
  --ro-bind / / --dev-bind /dev /dev --proc /proc \
  --tmpfs /usr/share --dir /usr/share/carla \
  --ro-bind /var/tmp/portage/media-sound/carla-2.5.10/image/usr/lib64/carla /usr/lib64/carla \
  --setenv HOME /tmp/codex/media-sound/carla-2.5.10/gentoo-smoke-home \
  --setenv XDG_CACHE_HOME /tmp/codex/media-sound/carla-2.5.10/gentoo-smoke-cache \
  --setenv XDG_CONFIG_HOME /tmp/codex/media-sound/carla-2.5.10/gentoo-smoke-config \
  /var/tmp/portage/media-sound/carla-2.5.10/image/usr/bin/carla-single internal midisplit
```

The launcher exited 2 with exactly:

```
Carla resource folder does not exist, is Carla installed?
```

It did not reach `carla-bridge-native`; there was no traceback,
missing-library diagnostic, or crash.  Since the resources required by the
launcher do not exist in the intentional headless configuration, retaining
the corrected script would still knowingly install a nonfunctional command.
`src_install` therefore removes `${ED}/usr/bin/carla-single` with a
failure-checked `rm -v ... || die`.

After that decision, all now-unused Python machinery and launcher rewriting
were removed: `PYTHON_COMPAT`, `python-single-r1`, `REQUIRED_USE`,
`${PYTHON_DEPS}`, and the custom `src_prepare`.  The headless installed image
contains no Python program from this ebuild and no longer acquires a Python
dependency merely for a launcher that is removed.

### Final native build and install-image results

Both hosts used their existing effective USE configuration without an
override.  `server01` used only the temporary overlay below `/tmp/codex`;
its local repository was not modified.

| | arm64 | amd64 |
|---|---|---|
| Host | `gentoo` | `server01` |
| Effective USE (`build-info/USE`) | `X alsa arm64 elibc_glibc fluidsynth jack kernel_linux osc pulseaudio sdl sndfile` | `X abi_x86_64 alsa amd64 elibc_glibc fluidsynth jack kernel_linux osc pulseaudio sdl sndfile` |
| Final build command | `ebuild media-sound/carla/carla-2.5.10.ebuild clean unpack prepare configure compile install` | `ebuild /tmp/codex/media-sound/carla-2.5.10/overlay/media-sound/carla/carla-2.5.10.ebuild clean unpack prepare configure compile install` |
| Compile/install result | exit 0; source compiled and install image completed | same |
| `carla-single` in final image | absent by intentional failure-checked removal | same |
| `/usr/lib64/carla` | present | present |
| `/usr/share/carla/resources` | absent, as expected for `HAVE_PYQT=false` | same |
| `/usr/lib64/carla/carla-bridge-native` | present and executable | same |
| Installed ELF files | 15 | 15 |
| Unresolved libraries | none | none |

Final build logs:

```
gentoo:  /tmp/codex/media-sound/carla-2.5.10/gentoo-arm64-no-python-build.log
server01:/tmp/codex/media-sound/carla-2.5.10/server01-amd64-no-python-build.log
```

The existing bundled-WDL patch applied successfully in both final builds.
There is no custom `src_prepare`; the sequence
`Applying carla-2.5.10-fix-eel2-strict-aliasing.patch` followed by
`>>> Source prepared.` in each log confirms that EAPI 8's default preparation
phase consumed the preserved global `PATCHES` array.
Focused searches for strict-aliasing warnings, the original
`glue_port.h:846-847` diagnostics, `QA Notice`, severe warnings, text
relocations, executable stacks, and unresolved SONAMEs produced no matches.
All 15 installed ELF files on each host were checked with `ldd` using the
install-image Carla library directories; none reported `not found`.

The headless package retains its engine, discovery binary, bridges,
libraries, and LV2 plugin files.  It does not provide the `carla-single`
convenience command, the PyQt GUI, GUI/resource binaries, interactive plugin
hosting through that launcher, or a full audio-processing runtime test.

## 2026-08-21 — bundled WDL/EEL2 strict-aliasing fix

### Defect and patch

The release archive contains the affected file at:

```
Carla-2.5.10/source/modules/ysfx/thirdparty/WDL/source/WDL/eel2/glue_port.h
```

Its `EEL_BC_INVSQRT` implementation converted between `float` and `int` by
dereferencing incompatible pointers.  GCC consequently emitted severe
strict-aliasing QA warnings for the original lines 846-847 on arm64.

`files/carla-2.5.10-fix-eel2-strict-aliasing.patch` replaces both pointer
puns with `memcpy`, uses `uint32_t` for the 32-bit representation, and keeps
the original magic-constant calculation and Newton refinement.  It includes
`<stdint.h>` and `<string.h>` explicitly.  A negative-size typedef provides
a compile-time assertion that `sizeof(float) == sizeof(uint32_t)`; the arm64
portable EEL2 build compiled this assertion successfully.  The patch is
applied from the ebuild's global `PATCHES` array by the EAPI 8 default
`src_prepare`.  The ebuild does not override that phase.  No warning
suppression or `-fno-strict-aliasing` was added.

The source archive was inspected with:

```
tar -tzf /var/cache/distfiles/carla-2.5.10.tar.gz | rg 'glue_port\.h$'
tar -xzf /var/cache/distfiles/carla-2.5.10.tar.gz -C /tmp/codex/media-sound/carla-2.5.10
sed -n '810,875p' /tmp/codex/media-sound/carla-2.5.10/Carla-2.5.10/source/modules/ysfx/thirdparty/WDL/source/WDL/eel2/glue_port.h
patch --dry-run -p1 -d /tmp/codex/media-sound/carla-2.5.10/Carla-2.5.10 < media-sound/carla/files/carla-2.5.10-fix-eel2-strict-aliasing.patch
```

### Existing-report searches

GitHub issue searches in `falkTX/Carla` used `strict aliasing glue_port`,
`5f3759df glue_port`, and `EEL_BC_INVSQRT`; a search in
`justinfrankel/WDL` used `strict aliasing EEL`.  No matching issue was found.
GitHub code searches confirmed that current upstream WDL still contains the
same code in
[`WDL/eel2/glue_port.h`](https://github.com/justinfrankel/WDL/blob/8338e8193e4c1523c9eb0ec99d1815e14d062375/WDL/eel2/glue_port.h).

Gentoo Bugzilla REST quick searches used `carla strict aliasing`,
`media-sound/carla`, `glue_port.h`, and `EEL2 strict aliasing`.  No matching
defect report was found by those searches.  The sole Carla result was the
unrelated [bug 561582](https://bugs.gentoo.org/561582),
“media-sound/carla-9999: new package”.  No upstream or Gentoo report was
opened.

### Native build and install-image results

Both hosts used their existing effective USE configuration without an
override.

| | arm64 | amd64 |
|---|---|---|
| Host | `gentoo` (current host) | `server01` (SSH) |
| Effective USE (`build-info/USE`) | `X alsa arm64 elibc_glibc fluidsynth jack kernel_linux osc pulseaudio python_single_target_python3_14 sdl sndfile` | `X abi_x86_64 alsa amd64 elibc_glibc fluidsynth jack kernel_linux osc pulseaudio python_single_target_python3_14 sdl sndfile` |
| Build command | `ebuild media-sound/carla/carla-2.5.10.ebuild clean unpack prepare configure compile install` | `ebuild /tmp/codex/media-sound/carla-2.5.10/overlay/media-sound/carla/carla-2.5.10.ebuild clean unpack prepare configure compile install` |
| Compile/install result | exit 0; `>>> Source compiled.` and `>>> Completed installing` | exit 0; `>>> Source compiled.` and `>>> Completed installing` |
| Installed ELF files | 15 | 15 |
| Unresolved libraries (`ldd`) | none | none |
| Non-GUI smoke check | `carla-discovery-native` printed its usage safely; expected exit 1 without required arguments | same |

For `server01`, the package plus minimal overlay metadata was copied only to
`/tmp/codex/media-sound/carla-2.5.10/overlay`.  Its local Git repository was
not changed.  The temporary overlay caused non-fatal startup diagnostics
about inaccessible `/etc/gitconfig` and the directory not being a Git
checkout; patching, compilation, and installation continued successfully.

Full build logs:

```
gentoo:  /tmp/codex/media-sound/carla-2.5.10/gentoo-arm64-build.log
server01:/tmp/codex/media-sound/carla-2.5.10/server01-amd64-build.log
```

The logs were checked with focused searches for `strict-alias`, the original
`glue_port.h:846` and `glue_port.h:847` locations, `QA Notice`, `severe`, text
relocations, executable stacks, unresolved SONAMEs, and `not found`.  The
only strict-alias text was the patch filename itself; the original warnings
were absent on both architectures.  No new severe QA warnings or other
searched QA markers appeared.  Ordinary upstream compiler warnings remain,
including deprecation and unused/class-memory diagnostics; none was emitted
from the corrected conversions.

Both install images contained `carla-discovery-native`, Carla bridge and
library binaries, `/usr/lib64/lv2/carla.lv2/carla.so`, the LV2 manifest, and
the generated LV2 TTL files.  Every installed ELF was passed to `ldd` with
the install-image Carla library directories in `LD_LIBRARY_PATH`; none
reported `not found`.

The smoke check intentionally did not start a GUI, connect to JACK/ALSA,
load third-party plugins, or process audio.  Those real runtime behaviours,
interactive plugin hosting, and GUI functionality remain untested.  Carla's
Qt/Python GUI is not built by this ebuild because PyQt is unavailable.

### Static QA and Manifest

The repository uses a thin Manifest, so adding the `${FILESDIR}` patch did
not change `media-sound/carla/Manifest`.

```
pkgdev manifest media-sound/carla
# manifests are up to date

XDG_CACHE_HOME=/tmp/codex/media-sound/carla-2.5.10/pkgcheck-cache pkgcheck scan media-sound/carla
# exit 0, no output
```

The applicable Gentoo references were the current Devmanual `PATCHES` and
`src_prepare` documentation and PMS 8's definitions of `${FILESDIR}` and
default phase behaviour.
