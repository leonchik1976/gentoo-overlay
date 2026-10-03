# Updating n8n

1. Download and verify the exact stable upstream tag, then update `PV` by
   copying the ebuild and changing `PNPM_VERSION` and other version-specific
   artifact metadata as needed.
2. Extract the tag under `/tmp/codex/app-misc/n8n-<version>`.
3. Regenerate the locked artifact list:

       scripts/generate-n8n-pnpm-deps.py \
         <version> \
         /tmp/codex/app-misc/n8n-<version>/source/pnpm-lock.yaml \
         eclass/n8n-pnpm-deps-<version>.eclass

4. Review direct-URL dependencies, upstream patches, lifecycle-script packages,
   native addons, Node requirements, licenses, and the production deployment
   script. Update the ebuild patches and native build list from evidence.
5. Run `pkgdev manifest app-misc/n8n`, then perform a clean build with an empty
   Portage build directory and `FEATURES=network-sandbox`.
6. Run `pkgcheck scan app-misc/n8n acct-user/n8n acct-group/n8n` and repeat the
   native-load and staged startup checks on amd64 and arm64.

The generated eclass is deterministic for a given version and
`pnpm-lock.yaml`. It declares one Portage distfile for each entry in the
lockfile's `packages` mapping. Its version guard makes an ebuild fail during
metadata evaluation if a later regeneration has replaced the shared eclass
with another n8n version's closure. The ebuild derives pnpm's local registry
metadata cache from that same mapping so legacy `pnpm deploy` can resolve
locked peer ranges without network access.

Generated distfile aliases longer than 50 characters use a compact SHA-256 URI
prefix. Keep aliases short: in EAPI 8 Portage exports the complete `A` value to
every phase, and a single environment string longer than Linux permits makes
phase startup fail with `E2BIG` before the ebuild runs.

Each ebuild inherits a version-specific dependency eclass, so generating a
new closure does not alter another release. Check local dependency atoms before
removing superseded ebuilds.

pnpm 12 uses native executables from `@pnpm/exe.linux-x64` and
`@pnpm/exe.linux-arm64`. Fetch them as declared distfiles, alongside the pnpm
wrapper payload; never let its wrapper download a binary during an ebuild phase.
The package-manager lockfile is the first YAML document; the workspace closure
is the last. The store remains v11, but registry metadata now uses the encoded
`https%3A+registry.npmjs.org` directory. Refresh metadata before deployment.

The 2.34.5 dependency closure contains 3,641 external artifacts. Allow at
least 15 GiB on the Portage build filesystem and 2 GiB on `/usr`; native
compilation and the workspace build can take several minutes. Re-audit every
`.node`, ELF, Mach-O, and PE file after each update. In particular, confirm that the
architecture-aware pruning still keeps only the glibc `agent-browser` binary
for `${ARCH}`, that the three locally built addons still load, and that no new
prebuilt matrix or native compilation intermediates enter the image.
