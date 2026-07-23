# Updating n8n

1. Download and verify the exact stable upstream tag, then update `PV` by
   copying the ebuild and changing `PNPM_VERSION` and other version-specific
   artifact metadata as needed.
2. Extract the tag under `/tmp/codex/app-misc/n8n-<version>`.
3. Regenerate the locked artifact list:

       scripts/generate-n8n-pnpm-deps.py \
         <version> \
         /tmp/codex/app-misc/n8n-<version>/source/pnpm-lock.yaml \
         eclass/n8n-pnpm-deps.eclass

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

This overlay supports only one n8n ebuild and generated dependency closure at
a time. Before regenerating the shared eclass for a new version, remove the
previous n8n ebuild or convert the generated eclasses and their inherit calls
to version-specific filenames. The version guard prevents silent use of the
wrong closure; it does not allow multiple n8n versions to coexist with one
shared eclass.

The 2.31.5 Manifest covers 2,156,082,043 bytes (about 2.01 GiB) of distfiles,
and its measured build completed 64 workspace tasks. Allow at least 15 GiB on
the Portage build filesystem and 2 GiB on `/usr`; native compilation and the
workspace build can take several minutes. Re-audit every `.node`, ELF, Mach-O,
and PE file after each update. In particular, confirm that the
architecture-aware pruning still keeps only the glibc `agent-browser` binary
for `${ARCH}`, that the three locally built addons still load, and that no new
prebuilt matrix or native compilation intermediates enter the image.
