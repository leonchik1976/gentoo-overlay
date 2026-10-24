# Maintaining the Nimbalyst source package

`app-editors/nimbalyst` compiles the tagged application's TypeScript, bundled
extensions, node-pty, and better-sqlite3. Electron, Sharp/libvips, ONNX Runtime,
and agent executables remain upstream prebuilt dependencies. In particular,
the assembled application is not entirely MIT-licensed or source-only.

The exact upstream source is authoritative for versions:

- https://github.com/nimbalyst/nimbalyst/tree/v0.82.1
- https://github.com/nimbalyst/nimbalyst/blob/v0.82.1/pnpm-lock.yaml
- https://github.com/nimbalyst/nimbalyst/blob/v0.82.1/packages/electron/package.json

## Updating dependency inputs

Extract the exact release into `/tmp/codex/app-editors/nimbalyst-VERSION/`.
Run the generator with Python and PyYAML available:

```sh
python3 scripts/generate-nimbalyst-npm-deps.py SOURCE_DIRECTORY \
    eclass/nimbalyst-npm-deps-VERSION.eclass
```

The generator reads both lockfile documents. It preserves versions and hashes,
keeps common and Linux amd64/arm64 glibc inputs, and rejects non-registry
resolutions or distfile collisions. It does not resolve dependency versions or
contact the network. Update the versioned inherit and the pinned Electron,
pnpm, and ripgrep versions only from the corresponding upstream source.

Generate the package Manifest with `pkgdev manifest` and run a package-scoped
`pkgcheck scan`. For a temporary distfile directory, use
`pkgdev manifest -d /tmp/codex/app-editors/nimbalyst-VERSION/distfiles app-editors/nimbalyst`.
Every dependency is fetched directly from its upstream registry/release URL;
no maintainer-hosted dependency tarball is required.

## Offline build preparation

The `files/nimbalyst-build.py` resource imports local tarballs using the pinned
pnpm CLI, checks their SHA512 against the upstream lockfile, and registers
registry identities for those same store records. Its version-specific SQLite
index format was checked against:

https://github.com/pnpm/pnpm/blob/v12.9.1/pnpm/crates/store-dir/src/store_index.rs

The package-file records are produced by pnpm itself. The helper aliases their
keys; it does not manufacture file hashes or decoded msgpack records. Review
this import when updating pnpm. The fixture and real Portage preparations must
work without registry access before accepting an update.

The frozen install skips all lifecycle scripts. The ebuild explicitly supplies
Electron, compiler headers, and ripgrep, then compiles the two native addons
with those local headers. Release-age registry checks are disabled for these
already frozen, Manifest-checked inputs; no dependency version is re-resolved.
Sharp's build-host libvips autodetection is disabled to preserve the selected
upstream runtime consistently across hosts.

The packaging patch disables vendor application updates for the Portage-owned
installation and fixes the Linux worker probe's executable selection. It does
not disable sandbox or native ABI checks. Build output is an unpacked payload;
creating an AppImage or Debian package is unnecessary for a Gentoo image.

## Validation

Use non-merging `ebuild` phases through `test install`, never `qmerge`, `merge`,
or a live-system package installation. `USE=test` exercises SQLite, ONNX module
loading, and a PTY shell using the actual packaged Electron executable. It does
not authenticate an agent, access personal databases, or run ONNX inference.

Validate arm64 only on `gentoo`, and amd64 on `leonids-pc` or one of the designated
amd64 hosts. Remote validation snapshots and all their build/cache files must
stay under `/tmp/codex/app-editors/nimbalyst-VERSION/`; never modify a remote
overlay checkout. Copy logs back to `gentoo`.

Audit final ELF dependencies separately on both architectures. Keep prebuilt
QA annotations restricted to the bundled runtimes; the locally compiled PTY
and SQLite addons must remain subject to compiler-flag and ELF checks. Retain
upstream legal notices, including Electron's full Chromium license inventory
and `resources/legal/THIRD_PARTY_LICENSES.json`. A successful upstream license
generator is not a replacement for inspecting newly introduced licenses.
