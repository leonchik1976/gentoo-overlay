# Janus 2.0.0: SPDX metadata correction

Date: 2026-11-05. All builds and metadata inspections below were newly
executed for this fix. Earlier Janus runtime-test and Python-target results
are not presented as reruns.

## Change and evidence

The original 2.0.0 metadata produces `License classifiers are deprecated.`
The exact [Janus 2.0.0 source distribution](https://pypi.org/pypi/janus/2.0.0/json)
was inspected and its SHA256 checked against a newly fetched PyPI response:
`0970f38e0e725400496c834a368a67ee551dc3b5ad0a257e132f5b46f2e77770`.
The shipped setup.cfg uses a free-form `license = Apache 2`, explicitly
lists `license_files = LICENSE`, and includes the deprecated Apache license
Trove classifier. The shipped LICENSE is the Apache License 2.0 text.

The patch changes only metadata/build requirements:

- In setup.cfg, replace `license` with `license_expression = Apache-2.0`.
- Keep `license_files = LICENSE` unchanged.
- Remove the license classifier and its adjacent empty separator.
- In pyproject.toml, raise setuptools' minimum from 51 to 77.0.3.

The updated ebuild appends `>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]`
to BDEPEND and applies that patch. `LICENSE="Apache-2.0"`, SLOT, both
unstable architecture keywords, the pytest configuration/dependency, and
`PYTHON_COMPAT=( python3_{12..15} python3_15t )` are preserved verbatim.
No warning filter, QA override, or warning suppression was introduced.

The user clarified that the package is not installed and requested no revision
bump. The fix is now applied directly to janus-2.0.0.ebuild; the experimental
r1 file was removed. Its ebuild body is byte-identical to the temporary copy
used for the ten builds below. Those logs retain the earlier r1 filename;
they were not rewritten or presented as newly rerun builds after this
filename-only correction.

Sources consulted:

- [Setuptools PEP 639 migration guide](https://setuptools.pypa.io/en/latest/userguide/license_migration.html)
  and [77.0.0 release notes](https://setuptools.pypa.io/en/latest/history.html#v77-0-0):
  PEP 639 support starts in 77, including SPDX expressions, metadata 2.4,
  and the `.dist-info/licenses` location. The selected floor is the tested
  early bugfix release 77.0.3, not a claim that 77.0.3 introduced the format.
- Current installed setuptools `dist.py`, `_core_metadata.py`, and
  `config/setupcfg.py`: distribution license-expression support and config
  parsing were inspected. The minimum-version wheel build below verifies
  the chosen setup.cfg spelling actually produces the modern header.
- [License Expression specification](https://packaging.python.org/en/latest/specifications/license-expression/).
- ::gentoo examples:
  `/var/db/repos/gentoo/dev-python/xmlschema/xmlschema-4.3.2.ebuild`
  explicitly requires setuptools >=77; pikepdf ebuilds in the same tree
  use a 77.0.3 floor. These are packaging examples, not policy requirements.
- Current distutils-r1/pypi eclass contracts. distutils-r1 supports EAPI 8,
  so the ebuild preserves EAPI 8.

No Janus ebuild was present in ::gentoo or ::guru. Local history was inspected
before editing, and the working tree was initially unchanged.

## Fresh builds for every target

Workspace on each host:
`/tmp/codex/dev-python/janus-2.0.0/spdx-metadata`.
Each target used a distinct fresh PORTAGE_TMPDIR. This avoids the pure-Python
optimization that could build one wheel and reuse it across implementations.
Each log was checked for its interpreter's gpep517 invocation and an actual
`running bdist_wheel` line.

Exact amd64 command loop, run from the Git checkout:

```sh
for target in python3_12 python3_13 python3_14 python3_15 python3_15t; do
    PYTHON_TARGETS="$target" \
    PORTAGE_TMPDIR=/tmp/codex/dev-python/janus-2.0.0/spdx-metadata/portage-"$target" \
    DISTDIR=/tmp/codex/dev-python/janus-2.0.0/distfiles \
    ebuild dev-python/janus/janus-2.0.0-r1.ebuild unpack prepare compile install
done
```

The loop's wrapper recorded each exit status and redirected each command to
`build-amd64-<target>.log`. VERIFICATION output:

```text
python3_12 fresh build exit: 0
python3_13 fresh build exit: 0
python3_14 fresh build exit: 0
python3_15 fresh build exit: 0
python3_15t fresh build exit: 0
```

The same five builds ran natively on gentoo (arm64), using a staged repository
under that package workspace. The remote ebuild path was
`/tmp/codex/dev-python/janus-2.0.0/spdx-metadata/repo/dev-python/janus/janus-2.0.0-r1.ebuild`.
Every result printed `fresh native build exit: 0`. Those logs are named
`build-arm64-<target>.log` and were copied back locally.

Thus all five declared targets received fresh builds on **leonids-pc/amd64**
and **gentoo/arm64**. The install phase populated only temporary build images;
it did not merge/install a package on either live system.

## Wheel metadata and license inspection

The temporary helper `inspect-wheels.py` inspected every wheel with zipfile
and email.parser. It asserted the project name/upstream version, metadata
version, SPDX header, explicit license-file header, absence of the legacy
License header and license classifiers, license-file bytes, and a hashed
license entry in RECORD.

Commands:

```sh
python3.15 /tmp/codex/dev-python/janus-2.0.0/spdx-metadata/inspect-wheels.py amd64
ssh gentoo 'python3.15 /tmp/codex/dev-python/janus-2.0.0/spdx-metadata/inspect-wheels.py arm64'
```

VERIFIED for all ten wheels; representative actual metadata/output:

```text
Metadata-Version: 2.4
Name: janus
Version: 2.0.0
License-Expression: Apache-2.0
License-File: LICENSE
Shipped license: janus-2.0.0.dist-info/licenses/LICENSE
Deprecated license classifiers: 0
```

Every license file was byte-identical to LICENSE extracted directly from the
upstream distfile, with SHA256:
`8b177cccb6ddec12a9fc97bd49e7e2bbcd92464625624bd8bdbfad799ae606e9`.
Results are in `wheels-amd64.log` and `wheels-arm64.log`. All native logs
were copied back to leonids-pc; no remote overlay checkout was edited.

## Minimum-backend check

A separate fully isolated Python 3.12 venv installed setuptools 77.0.3 and
wheel. A fresh source extraction received the same patch and was built with:

```sh
cd /tmp/codex/dev-python/janus-2.0.0/spdx-metadata/minimum-source/janus-2.0.0
/tmp/codex/dev-python/janus-2.0.0/spdx-metadata/backend77-isolated/bin/python -c 'import setuptools; print("setuptools:",setuptools.__version__); from setuptools.build_meta import build_wheel; print(build_wheel("/tmp/codex/dev-python/janus-2.0.0/spdx-metadata/minimum-wheel"))'
python3.15 /tmp/codex/dev-python/janus-2.0.0/spdx-metadata/inspect-wheels.py minimum
```

The build printed `setuptools: 77.0.3`; the resulting wheel satisfied the
same metadata/license assertions, including metadata 2.4, Apache-2.0,
LICENSE, and zero license classifiers. This tests the metadata-format floor
on Python 3.12; it does not claim that this older backend was tested with
every newer interpreter. Main builds use available target-compatible tools.

An initial tools venv sharing system site-packages produced unrelated pip
diagnostics about torch/filelock/fsspec. It was not used for this proof; the
minimum-backend check used the fully isolated venv instead. No live package
was uninstalled or modified.

## Warning results and remaining findings

The ten main logs were searched and the inspector asserted absence of the
specific warning. Literal summary:

```text
amd64: 5 fresh build logs; license-classifier warning occurrences=0; setuptools QA notice occurrences=0
arm64: 5 fresh build logs; license-classifier warning occurrences=0; setuptools QA notice occurrences=0
```

Remaining unsuppressed build messages on both hosts:

```text
UserWarning: setup.cfg: at [metadata]
version = attr: ... is forcing setuptools to override the version setuptools-scm did already set
When using setuptools-scm it's invalid to use setuptools dynamic version as well, please remove it.
Setuptools-scm is responsible for setting the version, forcing setuptools to override creates errors.
warning: no previously-included files matching '*.pyc' found anywhere in distribution
warning: build_py: byte-compiling is disabled, skipping.
warning: install_lib: byte-compiling is disabled, skipping.
```

The setuptools-scm warning concerns the unchanged version declaration, not
the corrected license metadata. No versioning mechanism was changed in this
small metadata fix. The isolated minimum-backend build had the unmatched
`*.pyc` message but no license-classifier warning. These results are not
described as an absence of all build warnings.

Scoped checks actually run:

```sh
bash -n dev-python/janus/janus-2.0.0-r1.ebuild
git diff --check
pkgdev manifest -d /tmp/codex/dev-python/janus-2.0.0/distfiles dev-python/janus
XDG_CACHE_HOME=/tmp/codex/dev-python/janus-2.0.0/spdx-metadata/qa-cache pkgcheck scan dev-python/janus
```

Syntax and diff checks produced no output. pkgdev reported
`manifests are up to date`; the thin Manifest did not change because the
upstream distfile is unchanged. The earlier scan while both ebuilds existed reported:

```text
dev-python/janus
  RedundantVersion: version 2.0.0: slot(0) keywords are overshadowed by version: 2.0.0-r1
```

The experimental r1 was subsequently removed at the user's request. The
final unrevisioned package was checked again with bash -n, pkgdev manifest,
and the same scoped pkgcheck command. The earlier RedundantVersion finding
no longer applies; no check was suppressed.

Final filename-correction checks: `bash -n dev-python/janus/janus-2.0.0.ebuild`
and `git diff --check` produced no output. pkgdev again reported
`manifests are up to date`. The final scoped pkgcheck exited 0 with no output,
recorded in `spdx-metadata/pkgcheck-unrevisioned.log`. No new builds were
needed for the byte-identical ebuild body after this filename-only correction.

The original pytest configuration remains intact. Runtime pytest suites
were not rerun for this metadata-only fix; the fresh validation here covers
all-target package builds and the resulting distribution metadata/licenses.

## Files and boundaries

Checkout changes:

- `dev-python/janus/janus-2.0.0.ebuild` (updated in place)
- `dev-python/janus/files/janus-2.0.0-spdx-license.patch`
- `docs/janus-2.0.0-spdx-validation.md`

The LICENSE value, metadata.xml, architecture keywords,
test settings, Python target coverage, and Manifest were not changed.
No registered overlay, user configuration, live-system packages, Git
branches, commits, or pushes were modified/performed.
