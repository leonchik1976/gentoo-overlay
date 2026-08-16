# Updating app-backup/restic-browser (arm64)

This overlay carries an arm64-only `restic-browser` ebuild because the
amd64 ebuild in `::guru` vendors its frontend `node_modules` as a single
prebuilt, x86_64-only tarball (its `@rollup/rollup-linux-*`,
`@esbuild/*`, and `@tauri-apps/cli-linux-*` optional native npm packages
are x86_64-gnu builds only). Rather than hosting an equivalent prebuilt
blob for arm64, this ebuild fetches the exact linux/arm64/glibc npm
dependency closure individually from `registry.npmjs.org` and assembles
`node_modules` from those distfiles in `src_prepare`.

The current (0.3.3) dependency closure is **not** generated from a fresh
`npm install` against upstream's own, unmodified `package.json` -- see
"Vaadin license" below for why -- but from a committed, tested,
reproducible lockfile:
`app-backup/restic-browser/files/restic-browser-0.3.3-vaadin-23.3.25-package-lock.json.gz`
(gzip-compressed to keep `files/` within pkgcheck's `SizeViolation`/
`TotalSizeViolation` thresholds -- `generate-restic-browser-npm-deps.py`
reads `.gz` lockfiles transparently, and `src_prepare` decompresses it on
install). That file was produced by applying
`app-backup/restic-browser/files/restic-browser-0.3.3-vaadin-23.3.25.patch`
to a scratch copy of upstream's `package.json`, running a real `npm
install` against the patched tree, and gzipping the resulting
`package-lock.json`. The same committed file is also installed
(decompressed) over the stock `package-lock.json` in `src_prepare` (see
`pkg_setup`'s `RESTIC_BROWSER_NPM_DEPS_VERSION` guard below), so there is
exactly one lockfile in play for a given ebuild version -- not a
generation-time copy and a separate build-time copy that could drift
apart.

To bump the version:

1. Extract the new upstream tag's source and run a real `npm install`
   (network-connected, outside the ebuild sandbox) against its own,
   unmodified `package.json` to get its own `package-lock.json`.
2. Check whether upstream's `@vaadin/*` version range still resolves to a
   commercially-licensed release -- see "Vaadin license" below. If so,
   produce a new, version-specific patch and commit a new pinned,
   gzip-compressed lockfile (both under
   `app-backup/restic-browser/files/`) before continuing, following the
   same procedure used for 0.3.3.
3. Regenerate the locked dependency arrays from the **committed** file
   for this version, not the scratch lockfile from step 1 (the generator
   accepts the `.gz` directly):

       scripts/generate-restic-browser-npm-deps.py \
         <version> \
         app-backup/restic-browser/files/restic-browser-<version>-vaadin-<pin>-package-lock.json.gz \
         /tmp/claude/app-backup/restic-browser-<version>/npm-deps.gen

   The generator refuses (`SystemExit`, non-zero exit) to emit an entry
   for any package whose lockfile-recorded `license` field is a URL --
   the pattern proprietary licenses use, including Vaadin's. This means
   accidentally pointing it at the unpinned lockfile from step 1 fails
   loudly instead of silently producing a mislicensed ebuild; it is not
   a substitute for step 2's manual check on a version bump, since a
   *different* package could newly go proprietary in a lockfile that
   still passes the check for everything else.
4. Paste the generated `RESTIC_BROWSER_NPM_DEPS_VERSION`,
   `RESTIC_BROWSER_NPM_SRC_URI`, and `RESTIC_BROWSER_NPM_PATHS` into the
   new ebuild, replacing the previous version's. `pkg_setup` dies if
   `RESTIC_BROWSER_NPM_DEPS_VERSION` doesn't match `PV`, so forgetting
   this (or pasting arrays generated for the wrong version) is caught at
   build time rather than silently shipping a mismatched dependency set.
5. Re-check `src_prepare`'s `node_modules/.bin` symlinks: they only cover
   the binaries `npm run build` (`tsc && vite build`) invokes directly.
   If upstream's `package.json` `scripts.build` changes, or a new
   directly-invoked binary is added, add a matching symlink.
6. Confirm the crates tarball referenced from GitLab (`${P}-crates.tar.xz`,
   produced by `::guru`'s `pycargoebuild`-based ebuild) still applies
   unmodified — it is pure Rust source and is not architecture-specific.
7. Run `pkgdev manifest app-backup/restic-browser` if (and only if) this
   version bump changed which distfiles `SRC_URI` fetches -- a new
   upstream release tarball, a new/changed npm dependency closure, or a
   crates-tarball bump all do. Under this repo's `thin-manifests = true`
   (`metadata/layout.conf`), `Manifest` records only `SRC_URI`-fetched
   `DIST` entries; it does not hash `files/` content at all (verified: an
   edit to a `files/*.patch` or `files/*.json` leaves `pkgdev manifest`
   reporting "manifests are up to date"). So adding or editing the
   `files/*.patch` or `files/*-package-lock.json` themselves never
   requires re-running it on their own -- only a resulting `SRC_URI`
   change does.
8. Run `pkgcheck scan app-backup/restic-browser`. Expect exactly two
   findings and nothing else: `RequiredUseDefaults` and
   `RequiredUseUnsatisfiableInDev`, both on the `.../arm64/.../musl`
   profile, both because `REQUIRED_USE="elibc_glibc"` is unsatisfiable
   there. That pair is the deliberate, accepted consequence of this
   ebuild's glibc-only native npm addons (see "libc split" below) --
   `app-misc/n8n` in this overlay has the identical pair for the same
   reason. If a `files/*-package-lock.json.gz` is ever added uncompressed
   or gains bulk (e.g. a much larger future dependency closure), expect
   `SizeViolation`/`TotalSizeViolation` to reappear -- keep the lockfile
   gzipped rather than accepting those findings. Any *other* finding is a
   real regression to fix.
9. Build-test with
   `ebuild <path> clean unpack prepare configure compile install`
   (never `merge`/`qmerge` on a live system). Confirm `src_prepare`
   leaves the unpacked tree self-consistent: its `package.json` and
   `package-lock.json` should both show the pinned `@vaadin/*` versions
   (compare the installed, decompressed `package-lock.json` against
   `gunzip -c` of the committed `files/*-package-lock.json.gz` -- they
   must be byte-identical), and the assembled `node_modules` tree should
   contain exactly those pinned versions.

The generator only includes registry-hosted, single-root-directory npm
tarballs; it fails loudly if the lockfile ever gains a non-registry
(git/local) dependency, since that would need separate handling.

The libc split (`-gnu` vs `-musl` native-addon packages) is not encoded
in `package-lock.json`'s `os`/`cpu` fields, only in the package name, so
the generator excludes anything with `musl` in its name. The ebuild sets
`REQUIRED_USE="elibc_glibc"` to make that restriction explicit.

## Vaadin license (re-check on every version bump)

24 of the 26 vendored `@vaadin/*` npm packages ship
`"license": "https://vaadin.com/commercial-license-and-service-terms"`
**at the version upstream's own `package.json` `^23.3` range currently
resolves to (23.6.1)** -- the non-free Vaadin Commercial License and
Service Terms, not an open-source license (the other 2,
`vaadin-development-mode-detector` and `vaadin-usage-statistics`, are
independently versioned and stayed Apache-2.0 throughout). The current
CVDL terms (fetched and verified 2026-08-16, version 9, updated
2026-06-29) define "Use Licensed Software" (Section 1.28) to include
"using Licensed Software ... as a part of ... an automated build
process", and grant that right (Section 4.3.1.2) only "based on full
payment of the Subscription fee" -- there is no free tier for these
components at 23.5.0+. `::guru`'s amd64 ebuild vendors the same
commercially-licensed 23.6.1 packages without declaring this in `LICENSE`
or restricting redistribution; treat that as a packaging gap in `::guru`,
not as evidence the packages are freely usable.

**Resolution used here:** confirmed via the npm registry that every
affected `@vaadin/*` package was still Apache-2.0 through 23.4.2, and
flipped to the commercial license starting at 23.5.0. Upstream's own
v0.3.0 release pinned these to `23.3.25` (still Apache-2.0). This ebuild
pins the same 24 packages to `23.3.25` via
`files/restic-browser-0.3.3-vaadin-23.3.25.patch`, which edits
`package.json`'s direct `@vaadin/*` `dependencies` and adds an
`overrides` block for the transitive-only ones. That patch is applied
for real via `PATCHES=` in `src_prepare` -- not because the build needs
it (the hand-assembled `node_modules` never reads `package.json` or
`package-lock.json`), but so the unpacked source tree stays consistent
with what is actually vendored.

The *dependency resolution* itself (which exact transitive versions each
pinned `@vaadin/*` package pulls in) was produced separately, since npm
resolution is not reproducible from the patch alone -- a later `npm
install` run could resolve unrelated transitive packages to whatever is
newest that day. Apply the same patch to a scratch copy of the source and
run a real `npm install` there to get `package-lock.json`, gzip it, then
commit that as
`files/restic-browser-0.3.3-vaadin-23.3.25-package-lock.json.gz` -- this
is the actual input to the generator (which reads `.gz` lockfiles
transparently), and is also the file `src_prepare` decompresses into the
build tree, so there is one committed source of truth rather than three
independent copies.

Verified compatible with 0.3.3's actual TypeScript/Lit source: `npm run
build` (`tsc && vite build`) type-checks and bundles cleanly against the
pinned tree, and a real Tauri build's binary renders its Vaadin-based UI
correctly (checked visually under Xvfb).

Re-verify this on every version bump:

1. Build the new version's `package.json`/`package-lock.json` normally
   first (real `npm install` against upstream's own, unmodified
   `package.json`), and check whether upstream's `^23.x` (or newer
   major) range still resolves to a commercially-licensed version --
   grep each `@vaadin/*` tarball's `package.json` for `"license"`, or
   check `https://registry.npmjs.org/@vaadin/grid` for the version
   history.
2. If so, repeat the override: copy the source tree, edit `package.json`
   to pin the direct `@vaadin/*` dependencies and add an `overrides`
   block for the transitive-only ones to the newest Apache-2.0 version
   available, generate a new
   `files/restic-browser-<version>-vaadin-<pin>.patch` from the diff,
   then run a real `npm install` against the patched tree to get a
   fresh, consistent `package-lock.json` -- do **not** delete the
   existing `package-lock.json` first, or npm will also re-resolve every
   *unrelated* dependency to today's latest matching version instead of
   preserving upstream's own tested resolutions. `gzip -9` the result and
   commit it as
   `files/restic-browser-<version>-vaadin-<pin>-package-lock.json.gz`,
   alongside the patch -- an uncompressed lockfile will trip pkgcheck's
   `SizeViolation`/`TotalSizeViolation`.
3. Rebuild the frontend (`npm run build`) and the full Tauri binary from
   that pinned tree to confirm compatibility before regenerating the
   ebuild's dependency arrays.
4. If no Apache-2.0 version of some now-required `@vaadin/*` component
   exists at all (e.g. a genuinely new commercial-only component gets
   added), packaging an older upstream release (e.g. 0.3.0) instead is
   the fallback -- do not vendor commercially-licensed packages.
