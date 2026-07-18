# Updating n8n task-runner dependencies

Only one n8n task-runner ebuild and generated dependency closure is supported
at a time. Extract the exact n8n release tag, then run:

```sh
scripts/generate-n8n-task-runner-deps.py VERSION /path/to/pnpm-lock.yaml eclass/n8n-task-runners-pnpm-deps.eclass
```

The generator starts at `packages/@n8n/task-runner`, follows workspace links
and locked external snapshots, and adds the upstream `moment`, SheetJS and
wa-sqlite compatibility artifacts. Review the counts and regenerate the
Manifest. Before replacing the shared eclass for a new release, remove the old
ebuild or adopt version-specific eclass filenames; the version guard prevents
silent misuse but does not support concurrent versions.

The generated eclass also publishes stable variables for special artifacts
used directly by the ebuild (`moment`, SheetJS, and `wa-sqlite`). These names
are derived from package identity; maintainers must not refer to numbered
aliases directly from the ebuild.

The launcher currently uses the deprecated `EGO_SUM` compatibility mode until
`n8n-task-runner-launcher-1.4.7-deps.tar.xz` has an authorized stable hosting
location. Generate the replacement module-cache archive from the launcher
source with:

```sh
GOMODCACHE="${PWD}/go-mod" go mod download -modcacherw
tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
  --pax-option=delete=atime,delete=ctime -c go-mod | xz -T0 -9e \
  > n8n-task-runner-launcher-1.4.7-deps.tar.xz
```

After hosting it, add its real stable URL to `SRC_URI`, remove `EGO_SUM`,
`go-module_set_globals`, the `EGO_SUM_SRC_URI` append, and the custom Go
distfile handling in `src_unpack()`. The archive must unpack as `go-mod/` in
`${WORKDIR}`.
