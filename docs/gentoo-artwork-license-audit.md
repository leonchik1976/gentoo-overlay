# gentoo-artwork: packaging and license investigation, 2026-11-16

The package was copied from `::gentoo/x11-themes/gentoo-artwork` into this
overlay. Revision `0.4.2-r2` updates the packaging, but **the historical artwork
is not cleared for redistribution**. The archive inventory is complete for
regular-file entries in the six distfiles; permission verification is not.
No archive was added to Git or published elsewhere. No copyright holder was
contacted and no license grant was invented.

## Changes and scope

- Retained `gentoo-artwork-0.4.2-r1.ebuild` and both original `files/` resources.
  In the imported r1, corrected the unsubstantiated blanket license declaration,
  added redistribution restrictions, and applied the overlay's unstable
  `~amd64 ~arm64` keyword policy. Its historical EAPI 7 implementation remains.
- Added r2 with EAPI 8, `xdg-utils`, conditional icon-cache hooks in
  `pkg_postinst` and `pkg_postrm`, installation helpers instead of raw copies
  into `${D}`, Prefix-aware removal paths, and line-oriented offensive filtering.
- Set `metadata.xml` maintainer to Leonid Kopylov,
  `leonchik1976@gmail.com`, and clarified the four existing local USE descriptions.
- Added the unversioned atom `x11-themes/gentoo-artwork` to
  `profiles/package.unmask`, as explicitly requested. This unmasks every version;
  it is not a statement of license clearance.
- Generated a thin Manifest according to this overlay's `metadata/layout.conf`.
  All six DIST entries and their original digests were preserved. The copied
  upstream full Manifest's AUX/EBUILD/MISC entries were removed by `pkgdev` as
  part of conversion to the overlay's configured thin format.
- Added `scripts/audit-gentoo-artwork.py` and the inventory/evidence files under
  `docs/gentoo-artwork-audit/`. The script reads archives without extracting them
  and uses Pillow for metadata inspection. Pillow is an audit-tool requirement,
  not an ebuild dependency.

The working tree was empty according to `git status --short` before editing.
The live configured overlay at `/var/db/repos/gentoo-overlay` was not edited.
For metadata checks against this checkout, `PORTDIR_OVERLAY` was set explicitly.
There was no commit, push, branch operation, merge, or live-system installation.

## EAPI and eclass contract

VERIFIED: [PMS 9, section 2.2](https://projects.gentoo.org/pms/9/pms.html)
defines EAPIs through 9. The current
[Devmanual EAPI guide](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html)
also describes EAPI 9. No newer EAPI was found in these official sources.

The initial EAPI 9 staging attempt reached `src_install` but reproduced the
existing icon-cache QA warning. This is already reported in
[bug 958080](https://bugs.gentoo.org/958080), currently CONFIRMED in the retrieved
bug search. Adding the documented cache hooks addresses that packaging issue.

Both the [xdg-utils documentation](https://devmanual.gentoo.org/eclass-reference/xdg-utils.eclass/index.html)
and `/var/db/repos/gentoo/eclass/xdg-utils.eclass` list supported EAPIs `7 8`;
the implementation rejects others. Therefore r2 uses **EAPI 8**, rather than
introducing an unsupported eclass inheritance or a private replacement helper.
The initial EAPI 9 trial is not the final validated implementation.

## Archive-by-archive license evidence

Each archive's size, BLAKE2B, and SHA512 was checked against the original
`::gentoo` Manifest. SHA256 hashes and exact member paths are recorded in the
[archive inventory](gentoo-artwork-audit/gentoo-artwork-archive-inventory.csv).
Counts below include documentation and repeated/overwritten files; they are
not counts of unique images.

| Exact distfile | Regular-file entries | Evidence and unresolved issue |
| --- | ---: | --- |
| [gentoo-artwork-0.2.tar.bz2](https://distfiles.gentoo.org/distfiles/c0/gentoo-artwork-0.2.tar.bz2) | 1001 | Icons, wallpapers, four compressed XPM splash images and `misc/Gentoo.kcsrc`; no explicit collection-wide grant located. |
| [gentoo-artwork-0.3.tar.bz2](https://distfiles.gentoo.org/distfiles/8f/gentoo-artwork-0.3.tar.bz2) | 102 | `pixmaps/CREDITS` attributes wallpaper filenames to contributors; attribution is not a license grant. |
| [gentoo-artwork-0.4.tar.bz2](https://distfiles.gentoo.org/distfiles/18/gentoo-artwork-0.4.tar.bz2) | 513 | Additional artwork, two SVGs, LILO bitmap and author note; no blanket grant located. Contains the two images reported in bug 132271. |
| [gentoo-artwork-0.4.1.tar.bz2](https://distfiles.gentoo.org/distfiles/56/gentoo-artwork-0.4.1.tar.bz2) | 7 | Additional wallpapers; no explicit grant located. |
| [gentoo-artwork-0.4.2.tar.bz2](https://distfiles.gentoo.org/distfiles/89/gentoo-artwork-0.4.2.tar.bz2) | 25 | Additional icons, two XCF templates and `icons/gentoo/l33t.txt`; the text identifies sources, not a license. |
| [gentoo-bubble-icons-20060811.tar.gz](https://distfiles.gentoo.org/distfiles/da/gentoo-bubble-icons-20060811.tar.gz) | 287 | 286 PNGs plus README. README explicitly specifies CC-BY-2.0, credits Wolven and the initial design by port001; underlying third-party rights remain unverified. |

VERIFIED: the tool printed these counts:

```text
archive_file_records: 1935
NO_EXPLICIT_LICENSE_GRANT_LOCATED: 1646
HISTORICAL_REDISTRIBUTION_CONCERN_REMOVED_BEFORE_INSTALL: 2
EXPLICIT_COLLECTION_NOTICE_UNDERLYING_RIGHTS_UNRESOLVED: 287
installed_files: 1924
```

The [installed inventory](gentoo-artwork-audit/gentoo-artwork-installed-inventory.csv)
maps 1,923 staged files to identical archive content, allowing for compressed
documentation. The remaining file is `usr/share/icons/gentoo/index.theme`,
which was separately compared byte-for-byte to the copied `files/index.theme`.
Its provenance is the attachment discussed in [bug 50988](https://bugs.gentoo.org/50988)
(RESOLVED FIXED); no explicit grant was found in the comments inspected.
Matching bytes identify possible origins, not permission or which duplicate
archive actually supplied a file during the historical overlay unpacking.

Text files, SVG/XML content, gzip-compressed XPMs, PNG text metadata including
compressed text, and JPEG metadata/EXIF were inspected. The only license-text
hits recorded by the tool were in the bubble-icons README. Pillow could not
parse the two XCF templates; printable strings were inspected instead, with no
grant found. These limitations are recorded in the
[evidence JSON](gentoo-artwork-audit/gentoo-artwork-audit-evidence.json).
This was not an authenticated, visual, file-by-file identification of every
third-party image or an exhaustive interpretation of every image-format field.

## What remains unresolved

VERIFIED: [bug 132271](https://bugs.gentoo.org/132271) is RESOLVED FIXED and
identifies `gentoo-blue-leaf-1024x768.jpg` and
`gentoo-blue-ute-1024x768.jpg`. Both are still members of the 0.4 distfile.
The ebuild deletes them before installation; neither appears in either native
staged image. That does not remove them from the redistributed source archive.

VERIFIED: [bug 139332](https://bugs.gentoo.org/139332) (RESOLVED FIXED) confirms
that ionbox.org and forum contributions were incorporated. It does not provide
individual third-party permissions. Original references currently fail to
establish those permissions: `https://www.gentoo.org/dyn/icons.xml` returned
404, forum topic 31958 returned a login requirement, and the Gentoo Gitweb
package history request returned 502. An official Gentoo GitHub mirror was
also searched for the original icon documentation without locating it.

The current [Gentoo Artwork history, revision 1409259](https://wiki.gentoo.org/index.php?title=Project:Artwork/Artwork&oldid=1409259)
explicitly distinguishes the licenses of individual base graphics. It records
CC-BY-SA-2.5 permissions for Larry-related artwork, including a 2011 permission
for the original head, and different notices for various logo variants.
The [Gentoo logo guidelines](https://www.gentoo.org/inside-gentoo/foundation/name-logo-guidelines.html)
identify CC-BY-SA-4.0 for the official logo. These are evidence for specific
base graphics, not automatic permission for contributors' compositions,
photographs, commercial-product graphics, or game artwork in these archives.

INFERRED: the mixture of source references, credits and identifiable product/game
names makes a single unqualified GPL-2 declaration unjustified. A filename
alone does not prove derivation or infringement. The inventory marks names as
review hints and records 73 filename attribution hints from CREDITS, without
treating either as proof of authorship or permission.

Both imported ebuilds now use the provisional classification:

```bash
LICENSE="all-rights-reserved icons? ( CC-BY-2.0 )"
RESTRICT="binchecks bindist mirror strip"
```

This follows the [Devmanual's treatment of existing packages with no explicit grant](https://devmanual.gentoo.org/general-concepts/licenses/index.html).
It records uncertainty and restricts distribution; it does **not** grant rights,
resolve possibly incompatible licenses, certify third-party material, or make
the archives suitable for publication. `RESTRICT=mirror` does not prevent
fetching an existing distfile from a mirror. The retained ebuild GPL header
licenses packaging code; it is not an artwork license grant.

NOT VERIFIED: full clearance of any artwork group, including the bubble icons'
incorporated material. To resolve this, each retained work needs an applicable
grant and required attribution for its contributor and incorporated material.
Unknown or incompatible works would need exclusion/replacement in an audited
release; the two historically reported images also need exclusion from any
newly distributed archive. Neither mass removal nor a replacement release was
performed in this first packaging/audit step. Private historical archives may
remain useful as investigation evidence, without being published.

## Dependencies and USE flags

VERIFIED: Portage metadata for r2 reports empty `DEPEND`, `RDEPEND`, `BDEPEND`,
and `IDEPEND`. The ebuild does not compile or convert artwork, execute GRUB/LILO,
or invoke KDE/GTK applications during its source phases. Its compression and
file-management tools are provided by the Gentoo base environment; see
`::gentoo/profiles/base/packages` and [PMS chapter 12](https://projects.gentoo.org/pms/9/pms.html).
No Python/Pillow dependency belongs in the ebuild.

`xdg-utils.eclass` declares no dependencies and skips cache updating when
`gtk-update-icon-cache` is absent. The same dependency-free hook pattern is
used by `::gentoo/x11-themes/hicolor-icon-theme/hicolor-icon-theme-0.17.ebuild`.
No mandatory GTK runtime dependency was added. `files/index.theme` does not
declare `Inherits`, so no inherited theme dependency was inferred.

[PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html#optional-runtime-dependencies)
does not require dependencies on every potential consumer of these resources.
All retained flags select installed content. None merely pulls in an optional
runtime dependency, and no policy exception or local convenience flag is used.

| Flag | Actual install-time effect | Registry / decision |
| --- | --- | --- |
| `grub` (default on) | Installs four legacy `.xpm.gz` splash images under `/usr/share/grub/splashimages`. | Existing local flag; description clarified. Does not promise a modern GRUB theme or force a bootloader installation. |
| `icons` (default on) | Installs the icon theme, templates and accompanying notices. Controls cache hooks. | Existing local flag; meaningful file selection. |
| `pixmaps` (default on) | Installs wallpaper/background files and CREDITS. | Existing local flag; meaningful file selection. |
| `kde` | Installs `Gentoo.kcsrc` into the historical `kdisplay/color-schemes` directory. | Existing global flag; legacy payload retained. Current Plasma consumption was not established. |
| `lilo` | Installs the bitmap splash image and its documentation. | Existing local flag; masked by base architecture policy and unmasked on amd64. No bootloader is installed. |
| `offensive` | Retains `pixmaps/1024x768/gentoo-revolution-1024x768.png` when pixmaps are installed. | Existing global flag; actual content selection, not copyright filtering. |

Registries inspected: `::gentoo/profiles/use.desc` and
`::gentoo/profiles/use.local.desc`. The four non-global flag descriptions remain
in `metadata.xml`; global flags are not redefined there. Relevant examples were
inspected in `::gentoo/x11-themes/hicolor-icon-theme`, `tango-icon-theme`,
`gentoo10-backgrounds`, and `windowmaker-themes`. No matching package or useful
matching artwork package was found in the local `::guru` file search.
Examples inform practice; they do not establish licensing or policy.

[Bug 203681](https://bugs.gentoo.org/203681) (RESOLVED FIXED) explains the four
local content-selection flags. [Bug 83461](https://bugs.gentoo.org/83461)
(RESOLVED FIXED) explains the offensive filter. Existing behavior allows all
content flags off, producing an empty package; this was reproduced and retained.
No artificial dependency or REQUIRED_USE constraint was introduced.

## Validation evidence

Exact commands, exit codes and QA output are saved in
[validation.json](gentoo-artwork-audit/validation.json). All validation was
scoped to this package. `pkgdev manifest -d /var/cache/distfiles
x11-themes/gentoo-artwork` initially printed:

```text
 * generating manifest: x11-themes/gentoo-artwork::local
```

Subsequent runs printed `manifests are up to date`.
The final scoped `pkgcheck scan --cache-dir
/tmp/codex/x11-themes/gentoo-artwork-0.4.2/pkgcheck-cache
x11-themes/gentoo-artwork` exited 0 and printed:

```text
x11-themes/gentoo-artwork
  RedundantVersion: version 0.4.2-r1: slot(0) keywords are overshadowed by version: 0.4.2-r2
```

This is a consequence of retaining the older ebuild, as requested by the local
preservation rules. It was not suppressed or fixed by deleting that version.
`bash -n` on both ebuilds and `git diff --check` exited 0 with no output.

VERIFIED: real non-merging Portage phase runs through `src_install` were performed:

```bash
sudo -n env USE='-* grub icons kde lilo offensive pixmaps' \
  PORTAGE_TMPDIR=/tmp/codex/x11-themes/gentoo-artwork-0.4.2/amd64-all \
  PORT_LOGDIR=/tmp/codex/x11-themes/gentoo-artwork-0.4.2/logs \
  ebuild x11-themes/gentoo-artwork/gentoo-artwork-0.4.2-r2.ebuild clean install
```

The amd64 run on `leonids-pc` exited 0 and printed:

```text
>>> Completed installing x11-themes/gentoo-artwork-0.4.2-r2 into /tmp/codex/x11-themes/gentoo-artwork-0.4.2/amd64-all/portage/x11-themes/gentoo-artwork-0.4.2-r2/image
```

Eight additional amd64 staging cases exercised none, each single content flag,
`kde lilo`, and `grub icons pixmaps`. Each recorded `exit_code: 0` and
`matches_expected: true`. Offensive content was absent when disabled and present
in the all-flags image when enabled. Portage's `use_reduce` evaluated all 64
USE combinations and printed `SRC_URI combinations checked: 64 all matched expected archives`.
See [src-uri-use-matrix.json](gentoo-artwork-audit/src-uri-use-matrix.json).

The native arm64 run on `gentoo` used the same command with an isolated staged
repository and `PORTAGE_TMPDIR` ending in `arm64-all`. It exited 0 and printed:

```text
>>> Completed installing x11-themes/gentoo-artwork-0.4.2-r2 into /tmp/codex/x11-themes/gentoo-artwork-0.4.2/arm64-all/portage/x11-themes/gentoo-artwork-0.4.2-r2/image
```

Its effective USE contained `grub icons kde offensive pixmaps`; the profile
masked `lilo` despite its presence in the requested USE string. The arm64 image
has 1,922 files, compared with 1,924 on amd64. The only difference is the LILO
bitmap and documentation. Comparison printed:

```text
All 1922 common native staged files have identical normalized SHA256 hashes
Native arm64 tested ebuild matches current r2 byte-for-byte
```

Documentation compression was normalized before comparing content hashes.
The arm64 log included host fstab/systemd mount hints; no host configuration
was changed in response. Remote work remained under the package workspace;
its overlay checkout was untouched. The tested ebuild, environment, build log
and hashes were copied back into
`/tmp/codex/x11-themes/gentoo-artwork-0.4.2/arm64-build-evidence.tar.gz`.

NOT VERIFIED: LILO payload staging on arm64, actual desktop theme selection,
GRUB/LILO boot display, live icon-cache hook execution, or source recompilation
(this is an artwork-copying package with no compile tasks or upstream tests).
The new r2 was staged on both native architectures, not installed on either.
The retained r1 did not receive a new phase test.

## Findings by category

- **Functional:** r2 stages the requested resources. Modern desktop/bootloader
  use of the legacy KDE and GRUB resources remains unverified.
- **QA:** r2 adds the missing icon-cache hooks tracked in bug 958080 and fixes
  raw `${D}` copies. The retained r1 still has its historical hook deficiency.
  The final scan reports the retained r1 as redundant.
- **Policy/licensing:** the unsupported blanket GPL-2 assertion was replaced
  by explicit uncertainty and restrictions. Redistribution clearance is still
  unresolved; changing metadata does not cure upstream permission gaps.
- **Style:** only r2 received localized shell/style updates. Original files/
  resources were preserved byte-for-byte.

The retirement bug [986570](https://bugs.gentoo.org/986570) remains CONFIRMED,
with removal scheduled for 2026-12-14 in the retrieved metadata. The local
package has been preserved and updated, but this audit does not establish a
basis for claiming that the licensing part of that bug is resolved.
