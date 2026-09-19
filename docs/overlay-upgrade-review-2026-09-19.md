# Overlay upgrade review, 2026-09-19

## ExpanDrive 2026.9.15_p885

The earlier validation report conflated two failures. The first temporary
build ran into the `/tmp` quota. After space was freed, an unprivileged
`ebuild ... install` reached `fowners root:root` for `chrome-sandbox` and
failed with `Operation not permitted`. Neither result identified an ebuild
or upstream image defect.

VERIFIED on `server01` (amd64): after removing only the failed temporary
Portage build tree, a fresh, non-merging phase test ran as root with
`DISTDIR` and `PORTAGE_TMPDIR` confined to
`/tmp/codex/net-misc/expandrive/expandrive-2026.9.15_p885`. The command was
`ebuild net-misc/expandrive/expandrive-2026.9.15_p885.ebuild clean unpack prepare configure compile install`.
It exited 0 and logged:

```text
>>> Completed installing net-misc/expandrive-2026.9.15_p885 into /tmp/codex/net-misc/expandrive/expandrive-2026.9.15_p885/portage-tmp/portage/net-misc/expandrive-2026.9.15_p885/image
* Final size of installed tree:  550868 KiB (537.9 MiB)
```

The temporary image's `/opt/ExpanDrive/chrome-sandbox` is `root:root` mode
`4711`; `/usr/bin/expandrive` points to `../../opt/ExpanDrive/expandrive`.
`find <image> -xtype l -print` produced no output. The raw log is at
`/tmp/codex/net-misc/expandrive/expandrive-2026.9.15_p885/build-root.log`.
No merge or live-system installation was performed.

The local policy calls for `KEYWORDS="~amd64 ~arm64"` on new ebuilds.
ExpanDrive is an unavoidable artifact-availability exception:
the [official Linux download endpoint](https://www.expandrive.com/api/download/expandrive?platform=linux&ext=deb)
redirected to `ExpanDrive_2026.09.15_amd64.deb` for this release, and
`dpkg-deb -f` on the exact downloaded artifact returned `Version:
2026.9.15-885` and `Architecture: amd64`. An `arch=arm64` query returned
HTTP 400 (`Invalid Query Parameters`). No arm64 Linux artifact was found
for the audited release, so the ebuild keeps `KEYWORDS="-* ~amd64"` and
must not claim arm64 availability.

NOT VERIFIED: ExpanDrive's interactive GUI and FUSE behavior. The other
incomplete amd64 tests from this upgrade review are the n8n server,
Zettlr, and ClickHouse server. Their prior phase-test failures remain
unresolved; the ExpanDrive phase result above does not verify those
packages. No new arm64 build or runtime validation was performed on
`gentoo` for this upgrade set.

## Zettlr 4.8.0

The new ebuild now uses the local-policy keyword line
`KEYWORDS="~amd64 ~arm64"`. This is a keyword declaration, not evidence
of an arm64 build. The 4.8.0 arm64 image and runtime still need validation
on `gentoo`.
