# Wine Proton on Gentoo arm64

This overlay builds Valve's Wine fork for an arm64 Linux host. It does not
provide the complete Steam Proton distribution. The official Gentoo ebuild
remains the choice for amd64 and x86 hosts.

EAPI 8 is required by the current `wine.eclass`. Native ELF components use
GCC/BFD, following the official Proton ebuild; Windows PE components use
Clang/LLD, following Gentoo's arm64 Wine configuration.

## Required local configuration

Gentoo currently forces `mingw` for `wine-proton` in the selected profile.
Repository-level overlay USE settings are processed before that profile and
cannot undo the force. Add this line to a file under
`/etc/portage/profile/package.use.force/` (or to the existing regular file):

```text
app-emulation/wine-proton -mingw
```

Then configure the package in `/etc/portage/package.use/`:

```text
app-emulation/wine-proton -mingw -crossdev-mingw -abi_x86_32 -abi_x86_64 -wow64
```

Accept `~arm64` for this package if it is not already accepted. Select the
overlay explicitly when necessary: this homelab's configured `local`
repository priority is lower than `gentoo`.

The configuration above builds native ARM64 Windows support. To enable x86
Windows translation, enable `wow64`; the shared Wine eclass then requires
`app-emulation/fex-xtajit[wow64]` and installs its integration symlinks.

For x86-64 Windows translation, also enable `arm64ec` and add this line to
`/etc/portage/profile/package.use.mask/` (or the existing regular file):

```text
app-emulation/wine-proton -arm64ec
```

This unmasks the flag inherited from Gentoo's architecture base profile.
`arm64ec` pulls in `app-emulation/fex-xtajit[arm64ec]`. Neither translation
mode is a claim that all games or Windows applications work.

Gecko and Mono integration are disabled: this release expects the older
x86-family addon artifacts, rather than the native arm64 Mono used by newer
Wine staging releases. The ebuild does not substitute a different addon
version. Gentoo's existing `ffmpeg` mask is retained.

See the installed `README.gentoo` for the upstream Gentoo notes about
Proton-specific prefix behavior and graphics integrations. Its DXVK and
VKD3D examples require independently compatible builds for the Windows
architecture in use.

## Sources

- Base: `::gentoo/app-emulation/wine-proton/wine-proton-11.0.2e.ebuild`
- arm64 reference: `::gentoo/app-emulation/wine-staging/wine-staging-11.20.ebuild`
- https://github.com/ValveSoftware/wine/tree/proton-wine-11.0-2e
- https://devmanual.gentoo.org/eclass-reference/wine.eclass/
- https://bugs.gentoo.org/977021 (GCC/BFD requirement)
- https://bugs.gentoo.org/959263 (SDL requirement)
