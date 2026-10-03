# Updating n8n task-runner dependencies

Extract the exact n8n release tag, then run:

```sh
scripts/generate-n8n-task-runner-deps.py VERSION /path/to/pnpm-lock.yaml eclass/n8n-task-runners-pnpm-deps-VERSION.eclass
```

Each ebuild inherits its own version-specific closure. The generators accept
single-document pnpm 11 locks and the workspace document of pnpm 12 locks.
See `README.n8n.md` for pnpm 12's native executable and cache requirements.

The generator starts at `packages/@n8n/task-runner`, follows workspace links
and locked external snapshots, and adds the upstream `moment` and wa-sqlite
compatibility artifacts. Review the counts and regenerate the
Manifest. Check local consumers before removing superseded ebuilds.

The generated eclass also publishes stable variables for special artifacts
used directly by the ebuild (`moment` and `wa-sqlite`). These names
are derived from package identity; maintainers must not refer to numbered
aliases directly from the ebuild.

Distfile aliases longer than 50 characters use the same compact SHA-256 URI
prefix as the full n8n closure. This keeps EAPI 8's exported `A` environment
variable below Linux's per-string `execve()` limit.

The launcher is built from its exact upstream source release with a loopback
health-check patch. Declare its Go module proxy `.mod`, `.info` and `.zip`
artifacts in `SRC_URI`, and stage a file-only `GOPROXY` during unpack. Audit
`go.mod` and `go.sum` for each launcher bump; do not introduce duplicate proxy
paths. Unchanged artifacts may retain aliases shared with an older launcher.
This workflow uses neither `EGO_SUM` nor a maintainer-hosted dependency tarball.
