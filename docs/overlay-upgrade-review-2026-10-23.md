# Overlay upgrades — 2026-10-23

Added 36 release ebuilds. Deferred Semgrep and GPaste after inspecting exact artifacts and constraints. Lens is included because the revised keyword policy permits retaining its upstream amd64-only architecture. The original `/tmp/report.txt` was an initial availability list, not a guarantee of packaging suitability.

No branch, commit, push, merge, qmerge, live-system package installation, service activation or remote checkout edit was performed. All validation images are under `/tmp/codex`.

## VERIFIED — release decisions and files

“Copy” below means copying the old ebuild to the new filename is sufficient for its packaging logic. Every updated package also has a regenerated Manifest. Source, published build metadata, licenses, patch applicability, optional-feature wiring and installed payload paths were inspected. No new USE flags were added.

| Package | Previous → new | Copy? / implementation | Release evidence |
|---|---|---|---|
| app-admin/aws-sam-cli | 1.169.0 → 1.170.0 | No. Widen cfn-lint upper bound to <1.59; account for shipped BSD/BSD-2/MIT notices; install THIRD-PARTY-LICENSES. | [metadata](https://pypi.org/pypi/aws-sam-cli/1.170.0/json) [source](https://files.pythonhosted.org/packages/0f/b0/216a29632ed601fd53b9ce97187799888c7ab875893bebc5bd6cf391a217/aws_sam_cli-1.170.0.tar.gz) [artifact](https://files.pythonhosted.org/packages/0f/b0/216a29632ed601fd53b9ce97187799888c7ab875893bebc5bd6cf391a217/aws_sam_cli-1.170.0.tar.gz) |
| app-admin/cockpit | 369 → 370 | Yes; existing packaging retained. | [source](https://codeload.github.com/cockpit-project/cockpit/tar.gz/refs/tags/370) [artifact](https://github.com/cockpit-project/cockpit/releases/download/370/cockpit-370.tar.xz) |
| app-admin/cockpit-machines | 358 → 359 | Yes; existing packaging retained. | [source](https://codeload.github.com/cockpit-project/cockpit-machines/tar.gz/refs/tags/359) [artifact](https://github.com/cockpit-project/cockpit-machines/releases/download/359/cockpit-machines-359.tar.xz) |
| app-admin/infracost-bin | 2.18.1 → 2.18.2 | Yes; existing packaging retained. | [source](https://codeload.github.com/infracost/cli/tar.gz/refs/tags/v2.18.2) [artifact](https://github.com/infracost/cli/releases/download/v2.18.2/infracost-linux-amd64.tar.gz) |
| app-admin/istioctl-bin | 1.31.2 → 1.31.3 | No. Correct license-scanner false positive and exclude go-digest documentation-only license from LICENSE. | [source](https://codeload.github.com/istio/istio/tar.gz/refs/tags/1.31.3) [artifact](https://github.com/istio/istio/releases/download/1.31.3/istioctl-1.31.3-linux-amd64.tar.gz) |
| app-admin/kiro-cli-bin | 2.33.0 → 2.33.1 | Yes; existing packaging retained. | [artifact](https://prod.download.cli.kiro.dev/stable/2.33.1/kirocli-x86_64-linux.tar.gz) |
| app-admin/pulumi-bin | 3.271.0 → 3.272.0 | Yes; existing packaging retained. | [source](https://codeload.github.com/pulumi/pulumi/tar.gz/refs/tags/v3.272.0) [artifact](https://github.com/pulumi/pulumi/releases/download/v3.272.0/pulumi-v3.272.0-linux-x64.tar.gz) |
| app-admin/tflint-bin | 0.64.0 → 0.65.0 | No. Add the licenses of embedded dependencies to the main MPL-2.0/BUSL-1.1 terms. | [source](https://codeload.github.com/terraform-linters/tflint/tar.gz/refs/tags/v0.65.0) [artifact](https://github.com/terraform-linters/tflint/releases/download/v0.65.0/tflint_linux_amd64.zip) |
| app-admin/vault-bin | 2.2.0 → 2.2.1 | Yes; existing packaging retained. | [source](https://codeload.github.com/hashicorp/vault/tar.gz/refs/tags/v2.2.1) [artifact](https://releases.hashicorp.com/vault/2.2.1/vault_2.2.1_linux_amd64.zip) |
| app-containers/lstk-bin | 1.4.1 → 1.4.2 | No. Remove the documentation-only go-digest license from LICENSE. | [source](https://codeload.github.com/localstack/lstk/tar.gz/refs/tags/v1.4.2) [artifact](https://github.com/localstack/lstk/releases/download/v1.4.2/lstk_1.4.2_linux_amd64.tar.gz) |
| app-crypt/yubioath-flutter-bin | 7.5.0_pre20261008 → 7.5.0_pre20261012 | No. Update exact CI artifact ID and source commit; retain arm64-only keywords and the archive's dain directory name. | [source](https://codeload.github.com/Yubico/yubioath-flutter/tar.gz/d4e255bedfc589ac51c24d2224f0a750aa07f19f) [artifact](https://nightly.link/Yubico/yubioath-flutter/actions/artifacts/11750879457.zip) |
| app-editors/cursor | 3.26.16 → 3.27.6 | No. Update immutable vendor build ID. | [artifact](https://downloads.cursor.com/production/f7119520544accb8dcf6d27119b9f1963d8ee5ae/linux/x64/deb/amd64/deb/cursor_3.27.6_amd64.deb) |
| app-editors/kiro | 1.4.13 → 1.4.26 | Yes; existing packaging retained. | [artifact](https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.4.26/deb/kiro-ide-1.4.26-stable-linux-x64.deb) |
| app-misc/grok-bot-bin | 0.75.0 → 0.75.2 | No. Update immutable vendor build ID. | [artifact](https://downloads.cursor.com/grokbot/stable/ec623d18b8a375d2ab29814cf974ddb791d8c33b/linux/x64/grok-bot_0.75.2_amd64.deb) |
| app-misc/openclaw-bin | 2026.10.5 → 2026.10.6 | No. Regenerate runtime lock, offline closure and compressed license inventory; raise Node bounds to >=24.22.1 <25 or >=26.12.1. | [source](https://codeload.github.com/openclaw/openclaw/tar.gz/refs/tags/v2026.10.6) [artifact](https://registry.npmjs.org/openclaw/-/openclaw-2026.10.6.tgz) |
| dev-db/clickhouse-bin | 26.9.24.8 → 26.9.25.15 | Yes; existing packaging retained. | [source](https://codeload.github.com/ClickHouse/ClickHouse/tar.gz/refs/tags/v26.9.25.15-stable) [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.25.15-stable/clickhouse-server-26.9.25.15-amd64.tgz) |
| dev-db/clickhouse-client-bin | 26.9.24.8 → 26.9.25.15 | Yes; existing packaging retained. | [source](https://codeload.github.com/ClickHouse/ClickHouse/tar.gz/refs/tags/v26.9.25.15-stable) [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.25.15-stable/clickhouse-client-26.9.25.15-amd64.tgz) |
| dev-db/clickhouse-common-static-bin | 26.9.24.8 → 26.9.25.15 | Yes; existing packaging retained. | [source](https://codeload.github.com/ClickHouse/ClickHouse/tar.gz/refs/tags/v26.9.25.15-stable) [artifact](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.25.15-stable/clickhouse-common-static-26.9.25.15-amd64.tgz) |
| dev-java/corretto-bin | 27.0.0.35.1 → 27.0.1.0.10 | Yes; existing packaging retained. | [source](https://codeload.github.com/corretto/corretto-27/tar.gz/refs/tags/27.0.1.0.10) [artifact](https://corretto.aws/downloads/resources/27.0.1.0.10/amazon-corretto-27.0.1.0.10-linux-x64.tar.gz) |
| dev-python/aws-lambda-powertools | 3.36.0 → 3.37.0 | No. Account for shipped MIT/Apache-2.0 third-party notices alongside MIT-0; install THIRD-PARTY-LICENSES. | [metadata](https://pypi.org/pypi/aws-lambda-powertools/3.37.0/json) [source](https://files.pythonhosted.org/packages/9d/40/7b964e95af5cd66c3a029aeb67a04915225edf436b296adf1a37d0dd909d/aws_lambda_powertools-3.37.0.tar.gz) [artifact](https://files.pythonhosted.org/packages/9d/40/7b964e95af5cd66c3a029aeb67a04915225edf436b296adf1a37d0dd909d/aws_lambda_powertools-3.37.0.tar.gz) |
| dev-python/boto3-stubs | 1.43.117 → 1.43.118 | Yes; existing packaging retained. | [metadata](https://pypi.org/pypi/boto3-stubs/1.43.118/json) [source](https://files.pythonhosted.org/packages/75/15/d5faf1c0eb6998a6b2d46598a42a00e0af02f48e89b9e02161282ecff0b4/boto3_stubs-1.43.118.tar.gz) [artifact](https://files.pythonhosted.org/packages/75/15/d5faf1c0eb6998a6b2d46598a42a00e0af02f48e89b9e02161282ecff0b4/boto3_stubs-1.43.118.tar.gz) |
| dev-python/botocore-stubs | 1.43.117 → 1.43.118 | Yes; existing packaging retained. | [metadata](https://pypi.org/pypi/botocore-stubs/1.43.118/json) [source](https://files.pythonhosted.org/packages/00/ee/7136f756dbc2b279ed9d9c21ab1f99c455fec0ffbbe285ce4ac77d19b943/botocore_stubs-1.43.118.tar.gz) [artifact](https://files.pythonhosted.org/packages/00/ee/7136f756dbc2b279ed9d9c21ab1f99c455fec0ffbbe285ce4ac77d19b943/botocore_stubs-1.43.118.tar.gz) |
| dev-python/cfn-lint | 1.53.3 → 1.58.0 | No. Drop obsolete SAM Translator dependency; require setuptools>=80.10.2; declare optional formatter dependencies only for tests; preserve inherited dependency variables; patch the offline schema fixture and mock the unit-test version request (review fix below). | [metadata](https://pypi.org/pypi/cfn-lint/1.58.0/json) [source](https://files.pythonhosted.org/packages/10/7e/d9395fa56b9f0f014e9e319daca03dd53133abefc2451b85f06ae4dc61dc/cfn_lint-1.58.0.tar.gz) [artifact](https://files.pythonhosted.org/packages/10/7e/d9395fa56b9f0f014e9e319daca03dd53133abefc2451b85f06ae4dc61dc/cfn_lint-1.58.0.tar.gz) |
| dev-python/mypy-boto3-lambda | 1.43.114 → 1.43.118 | Yes; existing packaging retained. | [metadata](https://pypi.org/pypi/mypy-boto3-lambda/1.43.118/json) [source](https://files.pythonhosted.org/packages/2a/15/711fe98771f61fd735942f867e86717351bbe04fae23c7b1a4f9b124b3de/mypy_boto3_lambda-1.43.118.tar.gz) [artifact](https://files.pythonhosted.org/packages/2a/15/711fe98771f61fd735942f867e86717351bbe04fae23c7b1a4f9b124b3de/mypy_boto3_lambda-1.43.118.tar.gz) |
| dev-python/mysql-connector-python | 26.7.0 → 26.10.0 | No. Reuse the existing, successfully applied license-classifier patch by its fixed versioned filename. | [metadata](https://pypi.org/pypi/mysql-connector-python/26.10.0/json) [source](https://codeload.github.com/mysql/mysql-connector-python/tar.gz/refs/tags/26.10.0) [artifact](https://github.com/mysql/mysql-connector-python/archive/refs/tags/26.10.0.tar.gz) |
| dev-python/posthog | 7.75.0 → 7.75.6 | Yes; existing packaging retained. | [metadata](https://pypi.org/pypi/posthog/7.75.6/json) [source](https://codeload.github.com/PostHog/posthog-python/tar.gz/refs/tags/posthog-v7.75.6) [artifact](https://github.com/PostHog/posthog-python/archive/refs/tags/posthog-v7.75.6.tar.gz) |
| dev-python/wassima | 2.1.4 → 2.1.5 | Yes; existing packaging retained. | [metadata](https://pypi.org/pypi/wassima/2.1.5/json) [source](https://files.pythonhosted.org/packages/5c/8e/9167e3e39e921833d35119849422cfbbba68c90ad0723c2a9c7965303195/wassima-2.1.5.tar.gz) [artifact](https://files.pythonhosted.org/packages/5c/8e/9167e3e39e921833d35119849422cfbbba68c90ad0723c2a9c7965303195/wassima-2.1.5.tar.gz) |
| dev-util/aws-cdk | 2.1146.0 → 2.1146.1 | Yes; existing packaging retained. | [artifact](https://registry.npmjs.org/aws-cdk/-/aws-cdk-2.1146.1.tgz) |
| dev-util/cursor-agent | 2026.10.19 → 2026.10.22 | No. Update immutable upstream build suffix; retain the matching bundled Node runtime and original launchers (review fix below). | [artifact](https://downloads.cursor.com/lab/2026.10.22-27dcf5f/linux/x64/agent-cli-package.tar.gz) |
| dev-util/github-copilot-bin | 1.1.30 → 1.1.31 | Yes; existing packaging retained. | [source](https://codeload.github.com/github/app/tar.gz/refs/tags/v1.1.31) [artifact](https://github.com/github/app/releases/download/v1.1.31/GitHub-Copilot-linux-x64.deb) |
| dev-util/github-copilot-cli-bin | 1.0.102 → 1.0.103 | Yes; existing packaging retained. | [source](https://codeload.github.com/github/copilot-cli/tar.gz/refs/tags/v1.0.103) [artifact](https://github.com/github/copilot-cli/releases/download/v1.0.103/copilot-linux-x64.tar.gz) |
| dev-util/postman-bin | 12.33.0 → 12.33.4 | Yes; existing packaging retained. | [artifact](https://dl.pstmn.io/download/version/12.33.4/linux64) |
| net-im/claude-desktop-bin | 3.1623.1 → 3.6556.2 | Yes; existing packaging retained. | [artifact](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_3.6556.2_amd64.deb) |
| sys-cluster/stern-bin | 1.34.0 → 1.35.0 | Yes; existing packaging retained. | [source](https://codeload.github.com/stern/stern/tar.gz/refs/tags/v1.35.0) [artifact](https://github.com/stern/stern/releases/download/v1.35.0/stern_1.35.0_linux_amd64.tar.gz) |
| www-client/brave-bin | 1.97.59 → 1.98.60 | Yes; existing packaging retained. | [source](https://codeload.github.com/brave/brave-browser/tar.gz/refs/tags/v1.98.60) [artifact](https://github.com/brave/brave-browser/releases/download/v1.98.60/brave-browser_1.98.60_amd64.deb) |
| sys-cluster/lens-bin | 2026.10.51501 → 2026.10.121159 | No. Retain amd64-only keywords under the revised policy; require glibc>=2.34; refresh native payload paths and unused musl-variant metadata exclusion; add verified 0BSD/BlueOak notices. | [source](https://downloads.k8slens.dev/ide/latest-linux.yml) [artifact](https://downloads.k8slens.dev/ide/Lens-2026.10.121159-latest.amd64.deb) |

All keywords match their previous ebuilds. Yubico remains `-* ~arm64`; Lens remains `~amd64`. The other updates retain `~amd64 ~arm64` (including any existing leading `-*`). Lens's [official installation documentation](https://docs.lenshq.io/k8slens/getting-started/install-lens/) describes Linux AMD64 availability.

## VERIFIED — deferred updates

- **dev-util/semgrep-bin:** the [1.182.1 PyPI release](https://pypi.org/pypi/semgrep/1.182.1/json) publishes wheels and a Python-only sdist. The matching [native source tag](https://api.github.com/repos/semgrep/semgrep/git/ref/tags/v1.182.1), [LICENSE](https://raw.githubusercontent.com/semgrep/semgrep/v1.182.1/LICENSE) and [source archive](https://codeload.github.com/semgrep/semgrep/tar.gz/refs/tags/v1.182.1) returned `HTTP Error 404: Not Found`, including the requested retry. The amd64 native core changed; 27 other bundled native files were byte-identical to the cached prior wheel. Older native source cannot be represented as the exact new core's source. Retained the existing 1.182.0 package unchanged.

- **x11-misc/gpaste:** [51.1 source](https://github.com/Keruspe/GPaste/archive/refs/tags/v51.1.tar.gz) raises library floors to GLib 2.90.0, GTK 4.24.0 and libadwaita 1.10.0. These are unavailable in the configured repositories. The proposed ebuild was withdrawn and the package Manifest restored; existing 51.0 and 50.10 files are unchanged. Literal proposed-version QA:

```text
  NonexistentDeps: version 51.1: DEPEND: nonexistent packages: >=dev-libs/glib-2.90.0:2, >=gnome-base/gnome-shell-51, >=gui-libs/gtk-4.24.0:4, >=gui-libs/libadwaita-1.10.0:1
  NonexistentDeps: version 51.1: RDEPEND: nonexistent packages: >=dev-libs/glib-2.90.0:2, >=gnome-base/gnome-shell-51, >=gui-libs/gtk-4.24.0:4, >=gui-libs/libadwaita-1.10.0:1
```

The attempted configure reported:

```text
Dependency gio-2.0 for host machine found: NO. Found 2.88.3 but need: '>= 2.90.0'
```

## VERIFIED — dependency and license review

SAM's [exact source](https://files.pythonhosted.org/packages/0f/b0/216a29632ed601fd53b9ce97187799888c7ab875893bebc5bd6cf391a217/aws_sam_cli-1.170.0.tar.gz) retains Lambda Builders 1.67.0 and SAM Translator 1.115.0 and permits cfn-lint >=1.52.0,<1.59. The [cfn-lint source metadata](https://pypi.org/pypi/cfn-lint/1.58.0/json) no longer lists SAM Translator as a base dependency. Its source build requires setuptools>=80.10.2. Optional graph/JUnit/SARIF integrations are test dependencies, not new runtime USE flags.

The ClickHouse server, client and common-static releases remain synchronized; their `${PV}`-based `~` dependencies select the new common-static version. No unrelated dependency pins were relaxed. The latest ebuild local dependency map has no mismatches against proposed release versions; this static map is not a complete profile resolver or a runtime compatibility test.

SAM's shipped THIRD-PARTY-LICENSES contains BSD, BSD-2 and MIT notices in addition to its Apache-2.0 main grant. [Powertools' exact release](https://pypi.org/pypi/aws-lambda-powertools/3.37.0/json) ships an MIT-0 LICENSE and additional MIT/Apache-2.0 notices; the license text takes precedence over its generic MIT metadata. Both new ebuilds install the notice file, confirmed in fresh temporary images.

TFLint's [release source](https://github.com/terraform-linters/tflint/archive/refs/tags/v0.65.0.tar.gz) carries MPL-2.0/BUSL-1.1 terms. Embedded module license texts additionally require Apache-2.0, BSD, BSD-2, MIT, Unicode-DFS-2016 and Unlicense accounting. Those identifiers were added. For Istioctl/Lstk, the audit corrected prior overbroad entries: [go-digest code](https://github.com/opencontainers/go-digest/blob/v1.0.0/digest.go) is Apache-2.0, while its separate LICENSE.docs covers documentation not shipped in these binary archives. [sigs.k8s.io/yaml's combined MIT/BSD text](https://github.com/kubernetes-sigs/yaml/blob/v1.6.0/LICENSE) was misclassified by lichen as ImageMagick. The actual text was read; the false ImageMagick identifier was not added to Vault/Stern and was removed from the new Istioctl ebuild.

OpenClaw's [published release](https://registry.npmjs.org/openclaw/2026.10.6) requires Node >=24.22.1 <25 or >=26.12.1. Its runtime-only lock was regenerated with lifecycle scripts disabled, starting from the prior lock to avoid unrelated dependency churn. The generator produced `354 entries` and `482 package license entries`; `354` integrity checks matched lockfile hashes. Only the OpenClaw and @openclaw/ai package versions changed in the license inventory; both new shipped LICENSE texts are MIT. The generated closure still assembles offline without npm installation during ebuild phases.

Lens's [exact Debian artifact](https://downloads.k8slens.dev/ide/Lens-2026.10.121159-latest.amd64.deb) was unpacked, including inspection of 765 ASAR legal texts. Shipped tslib has a 0BSD grant; isexe/lru-cache/minimatch and other modules ship BlueOak-1.0.0 texts. These were added to the prior license set. ELF inspection establishes the glibc 2.34 floor. Native payload paths changed from Node ABI 148 to 149 and add watcher/TypeScript components. The watcher loader selects its glibc or musl variant using detect-libc; the unused musl variant is excluded only from generated dependency metadata, alongside the existing extract-zip foreign variants. No binary ABI or SONAME was rewritten.

Corretto's [exact 27.0.1.0.10 source](https://codeload.github.com/corretto/corretto-27/tar.gz/refs/tags/27.0.1.0.10), all four published glibc/musl architecture archives and their legal trees were inspected. The earlier 27.0.0.36.1 GitHub release is AL2023-only and was not used as the binary update. Existing GPL-2-with-classpath-exception/Apache-2.0 packaging and legal-tree installation were retained.

## VERIFIED / INFERRED — Go license audit limits

`go version -m -json` was used on both downloaded architecture binaries. lichen ran against embedded module inventories with caches inside each package workspace; actual license texts were reviewed rather than accepting scanner labels mechanically. Architecture module sets match for Infracost, Istioctl, Pulumi, TFLint, Lstk and Stern; Vault's amd64 binary additionally embeds cpuid/v2. These are artifact inspections, not native arm64 execution or build validation.

lichen exits were 0 for Istioctl, TFLint, both Lstk executables, Stern and six Pulumi language executables; unresolved labels caused exit 1 for Infracost, the main Pulumi executable and Vault. Manual inspection resolved cupwriter/mpb as Unlicense, Aliyun's README as Apache-2.0, and vault-envelope-encryption-sdk source headers as MPL-2.0. Appdash-data's README points to parent/component licenses; its embedded asset scope was not exhaustively reconstructed. Infracost go-proto still has no LICENSE file in the inspected module. The pre-existing first-party coverage inference remains explicitly uncertain; this report does not certify complete binary license provenance.

## VERIFIED — commands and validation results

All local commands ran on **leonids-pc (amd64)**. Temporary roots are `/tmp/codex/<category>/<package>-<version>/upgrade-20261023/`. Commands actually used include:

```text
gh auth status
bash -n <new-ebuild>
pkgdev manifest -d <package-workspace>/distfiles <category/package>
pkgcheck scan --cache-dir <package-workspace>/cache/pkgcheck <category/package>
ebuild <new-ebuild> unpack prepare configure compile test install
sudo -n env <workspace-only paths> ebuild <new-ebuild> install
readelf -h -d -V <downloaded-ELF>
go version -m -json <downloaded-binary>
lichen -j <package-workspace>/audit/lichen-<binary>.json <downloaded-binary>
npm install --package-lock-only --ignore-scripts --omit=dev --no-audit --no-fund --cache <package-workspace>/npm-cache
python scripts/generate-openclaw-npm-deps.py 2026.10.6 <lock> <generated-arrays> <license-inventory>
git diff --check
```

Portage TMPDIR, logs, dependency cache, distfiles and package cache were overridden to package workspaces. Build scripts are temporary helpers under `/tmp/codex/overlay-upgrade-20261023/`. Ownership-only image staging used sudo; no merge/qmerge or live install phase ran. Lens was retried from a clean temporary build after a quota failure and stale cached phase metadata; the final result below supersedes those attempts.

| Package | syntax / Manifest / pkgcheck exits | amd64 on leonids-pc | arm64 on gentoo | Old versions |
|---|---|---|---|---|
| app-admin/aws-sam-cli | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| app-admin/cockpit | 0 / 0 / 0 | compile/image 0; test limited | NOT VERIFIED | retained: tests incomplete |
| app-admin/cockpit-machines | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| app-admin/infracost-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-admin/istioctl-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-admin/kiro-cli-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-admin/pulumi-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-admin/tflint-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-admin/vault-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-containers/lstk-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| app-crypt/yubioath-flutter-bin | 0 / 0 / 0 | not keyworded | phases/stage {'phases': 0, 'stage': 0} | removed after staging |
| app-editors/cursor | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| app-editors/kiro | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| app-misc/grok-bot-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| app-misc/openclaw-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-db/clickhouse-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| dev-db/clickhouse-client-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-db/clickhouse-common-static-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-java/corretto-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/aws-lambda-powertools | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/boto3-stubs | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/botocore-stubs | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/cfn-lint | 0 / 0 / 0 | compile/image 0; test dependencies missing | native image + Python 3.12–3.14 tests; dependency-limited | retained: tests incomplete |
| dev-python/mypy-boto3-lambda | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/mysql-connector-python | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-python/posthog | 0 / 0 / 0 | compile/image 0; test limited | NOT VERIFIED | retained: tests incomplete |
| dev-python/wassima | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-util/aws-cdk | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| dev-util/cursor-agent | 0 / 0 / 0 | phases/image 0; ABI/addons/offline CLI exercised | native image + ABI/addons/offline CLI exercised | removed after staging |
| dev-util/github-copilot-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| dev-util/github-copilot-cli-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| dev-util/postman-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| net-im/claude-desktop-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| sys-cluster/stern-bin | 0 / 0 / 0 | image retry exit 0 | NOT VERIFIED | removed after staging |
| www-client/brave-bin | 0 / 0 / 0 | phases/image exit 0 | NOT VERIFIED | removed after staging |
| sys-cluster/lens-bin | 0 / 0 / 0 | phases/image exit 0 | not keyworded | removed after staging |

“Compile/image” for a binary package means unpacking/preparation and temporary image staging, not recompiling upstream native binaries. Python packages produced wheels from release source. Cockpit compiled native C code. Cockpit Machines/AWS CDK/OpenClaw retain published frontend/JavaScript bundles. SAM also retains its upstream prebuilt RIE executables. GUI applications, cloud credentials, clusters and provider integrations were not exercised. Not every USE combination was built.

Yubico's arm64-only update ran on **gentoo (aarch64)** using a temporary staged repository, not a remote checkout. Recorded result: `{"phases": 0, "stage": 0}`. The image and logs were returned locally; this run's unique remote directory was removed. No amd64 keyword or test was added. The later review fixes below also validate Cursor Agent and cfn-lint natively on `gentoo`. Other arm64 builds/runtime checks remain **NOT VERIFIED**; local inspection of arm64 artifacts is not substituted for native validation. Lens has no upstream Linux arm64 artifact per the vendor documentation.

### Tests that remain unresolved

- Cockpit compiled and staged, but `make check` recorded `# TOTAL: 29`, `# PASS: 26`, `# FAIL: 3`. Certificate tests saw the live host's existing certificate instead of an empty test configuration; the socket helper hit `Unix socket path too long`. No live certificates were changed.
- cfn-lint built and staged. Its first Python test run recorded `6 failed, 3010 passed, 24 subtests passed`. JUnit/SARIF/pydot modules are absent on the host (now correctly declared for tests); one source assertion expects `NumberOfAssociations`, absent from the offline test fixture (the production schema does contain it; corrected below). No dependencies were installed and the failed tests were not hidden.
- PostHog built and staged, but the test phase stopped with `PackageNotFoundError: No package metadata was found for pytest-asyncio`; pytest-bdd is also absent on the host.
- Wassima recorded `41 passed, 3 skipped` for each of Python 3.12, 3.13 and 3.14. MySQL's server-independent unittest subsets returned `OK`/`OK (skipped=10)`; live MySQL integration tests were not run. Source sdists without tests remain limited to wheel/image validation.

Old Cockpit, cfn-lint and PostHog ebuilds are retained until their test limitations are resolved. Other successfully staged replacements had their superseded ebuilds removed at the user's request; unused historical patches/notices/lockfiles were preserved.

### Literal pkgcheck findings for the new versions

All recorded scoped pkgcheck commands returned exit 0; that does not mean no findings. The following is literal output for new versions. Profile solvability/elibc findings also appear for the prior retained or audited package versions; new Lens glibc constraints explicitly expose its musl incompatibility. RedundantVersion findings remain only where versions were intentionally retained for incomplete tests. No warning was suppressed.

#### app-admin/cockpit

```text
  RedundantVersion: version 369: slot(0) keywords are overshadowed by version: 370
  NonsolvableDepsInDev: version 370: nonsolvable depset(depend) keyword(~amd64) dev profile (default/linux/amd64/23.0/split-usr/musl) (4 total): solutions: [ >=sys-apps/systemd-235 ]
  NonsolvableDepsInDev: version 370: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/split-usr/musl) (4 total): solutions: [ >=net-misc/networkmanager-1.6[policykit,systemd], >=sys-apps/systemd-235, sys-auth/polkit[systemd], >=sys-fs/udisks-2.9[daemon,introspection,systemd] ]
  NonsolvableDepsInStable: version 370: nonsolvable depset(depend) keyword(~amd64) stable profile (default/linux/amd64/23.0/split-usr) (14 total): solutions: [ >=sys-apps/systemd-235 ]
  NonsolvableDepsInStable: version 370: nonsolvable depset(rdepend) keyword(~amd64) stable profile (default/linux/amd64/23.0/split-usr) (14 total): solutions: [ >=net-misc/networkmanager-1.6[policykit,systemd], >=sys-apps/systemd-235, sys-auth/polkit[systemd], >=sys-fs/udisks-2.9[daemon,introspection,systemd] ]
```

#### app-admin/infracost-bin

```text
  NonsolvableDepsInDev: version 2.18.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
  RequiredUseDefaults: version 2.18.2: profile: 'default/linux/amd64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.18.2: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total)
```

#### app-admin/kiro-cli-bin

```text
  NonsolvableDepsInDev: version 2.33.1: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
  NonsolvableDepsInDev: version 2.33.1: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.30 ]
  RequiredUseDefaults: version 2.33.1: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.33.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### app-admin/pulumi-bin

```text
  NonsolvableDepsInDev: version 3.272.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.29 ]
  NonsolvableDepsInDev: version 3.272.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.18 ]
  RequiredUseDefaults: version 3.272.0: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 3.272.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### app-editors/cursor

```text
  NonsolvableDepsInDev: version 3.27.6: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
```

#### app-editors/kiro

```text
  NonsolvableDepsInDev: version 1.4.26: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
  NonsolvableDepsInDev: version 1.4.26: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.28 ]
  RequiredUseDefaults: version 1.4.26: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.4.26: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### app-misc/grok-bot-bin

```text
  NonsolvableDepsInDev: version 0.75.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.38 ]
```

#### app-misc/openclaw-bin

```text
  RedundantVersion: version 2026.10.5: slot(0) keywords are overshadowed by version: 2026.10.6
  NonsolvableDepsInDev: version 2026.10.6: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.10.6: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ <net-libs/nodejs-25, >=net-libs/nodejs-24.22.1, >=net-libs/nodejs-26.12.1 ]
  RequiredUseDefaults: version 2026.10.6: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.6: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### dev-db/clickhouse-common-static-bin

```text
  NonsolvableDepsInDev: version 26.9.25.15: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.17 ]
  RequiredUseDefaults: version 26.9.25.15: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 26.9.25.15: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### dev-python/botocore-stubs

```text
  PythonCompatUpdate: version 1.43.118: PYTHON_COMPAT update available: python3_15
```

#### dev-python/cfn-lint

```text
  RedundantVersion: version 1.53.3: slot(0) keywords are overshadowed by version: 1.58.0
```

#### dev-python/mysql-connector-python

```text
  PythonCompatUpdate: version 26.10.0: PYTHON_COMPAT update available: python3_15
```

#### dev-python/posthog

```text
  RedundantVersion: version 7.75.0: slot(0) keywords are overshadowed by version: 7.75.6
```

#### dev-python/wassima

```text
  PythonCompatUpdate: version 2.1.5: PYTHON_COMPAT update available: python3_15
```

#### dev-util/aws-cdk

```text
  NonsolvableDepsInDev: version 2.1146.1: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-18 ]
  NonsolvableDepsInDev: version 2.1146.1: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-18[ssl] ]
```

#### dev-util/cursor-agent

```text
  NonsolvableDepsInDev: version 2026.10.22: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.28 ]
  NonsolvableDepsInDev: version 2026.10.22: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-22.1.0 ]
  NonsolvableDepsInDev: version 2026.10.22: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
```

#### dev-util/github-copilot-bin

```text
  RequiredUseDefaults: version 1.1.31: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.1.31: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### dev-util/github-copilot-cli-bin

```text
  NonsolvableDepsInDev: version 1.0.103: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
  RequiredUseDefaults: version 1.0.103: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.0.103: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### dev-util/postman-bin

```text
  NonsolvableDepsInDev: version 12.33.4: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.34 ]
```

#### net-im/claude-desktop-bin

```text
  NonsolvableDepsInDev: version 3.6556.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.34 ]
```

#### www-client/brave-bin

```text
  NonsolvableDepsInDev: version 1.98.60: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.25 ]
  RequiredUseDefaults: version 1.98.60: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.98.60: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

#### sys-cluster/lens-bin

```text
  NonsolvableDepsInDev: version 2026.10.121159: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
  RequiredUseDefaults: version 2026.10.121159: profile: 'default/linux/amd64/23.0/musl' (3 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.121159: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total)
```

### Relevant bug history and official references

The Gentoo Bugzilla summary searches are retained in the audit workspace. The cfn-lint results include resolved stabilization reports such as [983784](https://bugs.gentoo.org/983784); no new version pin was inferred from them. Historical GPaste [610960](https://bugs.gentoo.org/610960) concerns gnome-keybindings discovery; existing explicit installation directories were preserved during investigation. The Semgrep summary query returned an empty bugs list; that is not evidence that no issue exists under another name.

Consulted [PMS 9](https://projects.gentoo.org/pms/9/pms.html), [Devmanual EAPI guidance](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html), [dependency policy PG0001](https://projects.gentoo.org/qa/policy-guide/dependencies.html), and current local eclass documentation/implementation. EAPI 9 is current. EAPI 8 was retained where required by distutils-r1, Python, chromium-2, java-vm-2, meson, systemd, xdg, unpacker or other inherited eclass contracts. Native Gentoo/Guru examples and package history were inspected as prior art, not as overriding policy or independent license evidence.

### Repository changes and remaining work

Changed package files are the new ebuilds and corresponding Manifests in the table, 34 removed superseded ebuilds, the new OpenClaw lock under `scripts/locks/`, its compressed notice inventory under `app-misc/openclaw-bin/files/`, and this report. Manifest regeneration also prunes obsolete distfile records for removed versions. Existing unrelated packages, all excluded packages, the synchronized Elastic group, and deferred package files are unchanged.

Remaining work: native arm64 validation of the other dual-keyword updates; full runtime/integration and optional-USE coverage; resolution of the three test-limited packages before dropping their previous versions; complete attribution where upstream module provenance remains uncertain; Semgrep native source publication and availability of GPaste's required dependency versions.



### Follow-up: Cursor ABI and cfn-lint fixture review fixes

This follow-up changes only these six files relative to the working tree at the
start of the review-fix task:

- `dev-util/cursor-agent/cursor-agent-2026.10.22.ebuild`
- `dev-util/cursor-agent/Manifest`
- `dev-python/cfn-lint/cfn-lint-1.58.0.ebuild`
- `dev-python/cfn-lint/files/cfn-lint-1.58.0-offline-firewall-fixture.patch`
- `dev-python/cfn-lint/files/cfn-lint-1.58.0-offline-schema-update-test.patch`
- this document.

Existing staged upgrades were preserved. The Git index was not modified. No
branch, commit, push, merge, qmerge, live package installation or removal was
performed. Repository edits happened locally on **leonids-pc**. Remote work used
only the corresponding `/tmp/codex` staging directories on **gentoo**, not its
checkout. Logs were copied back to leonids-pc.

Evidence workspaces (the same paths were used for remote staging):

```text
Cursor: /tmp/codex/dev-util/cursor-agent-2026.10.22/review-fixes-x1q_lx0i
cfn-lint: /tmp/codex/dev-python/cfn-lint-1.58.0/review-fixes-1j7kptyu
```

Local logs are under `logs/`; returned native arm64 logs are under
`arm64-evidence/logs/`. Helper scripts and captured upstream API responses are
under `audit/`. These paths, rather than the earlier `upgrade-20261023` logs,
contain the final results of these fixes.

#### Cursor Agent: VERIFIED evidence and implementation

The exact [amd64 artifact](https://downloads.cursor.com/lab/2026.10.22-27dcf5f/linux/x64/agent-cli-package.tar.gz)
and [arm64 artifact](https://downloads.cursor.com/lab/2026.10.22-27dcf5f/linux/arm64/agent-cli-package.tar.gz)
both contain Node **24.22.1**, module ABI **137**. `readelf -Ws` finds
`node_register_module_v137` in all three copies of `better_sqlite3.node` in
each artifact. The system Node 26.12.1 reproduction on leonids-pc exited 1:

```text
was compiled against a different Node.js version using
NODE_MODULE_VERSION 137. This version of Node.js requires
NODE_MODULE_VERSION 147.
```

The ebuild now retains upstream `node`, preserves both launchers byte for byte,
marks Node executable, and removes the system Node dependency. Both launchers
select Node relative to their package directory; the main launcher also
resolves its invocation symlink. This follows the [Node ABI contract](https://nodejs.org/docs/v24.22.1/api/process.html#processversions),
not an assumption based on a lower dependency bound. Bundled ripgrep removal
and the existing arm64 removal of the unused Linux x64 tree-sitter prebuild
remain unchanged.

The runtime's [exact versioned license and third-party notices](https://raw.githubusercontent.com/nodejs/node/v24.22.1/LICENSE)
are now a Manifest-pinned distfile installed as `node-LICENSE` in package
documentation. `LICENSE` includes the retained runtime's MIT, Apache-2.0,
BSD/BSD-2, ISC, Unicode-3.0, ZLIB and BlueOak-1.0.0 notices alongside the
existing proprietary application license. The Cursor Manifest was regenerated
only to add this notice file; both application archive digests are unchanged.
No cfn-lint distfile changed, so its thin Manifest required no regeneration.

`audit/native-addons.json` inventories every `.node` file in both archives,
including machine type, registration symbols, needed libraries and symbol
versions. Each archive contains 20 such files. The three Mach-O/PE prebuilds
are foreign platform files and were inspected, not executed. The arm64 image
also excludes the existing unused Linux x64 prebuild. Actual runtime checks
covered all **17 amd64** and **16 arm64** native ELF files, including duplicate
paths. The three `test_extension.node` copies are SQLite loadable extensions,
so they were loaded with `Database.loadExtension()` rather than incorrectly
required as Node modules. All remaining native files were required separately
using bundled Node. An in-memory SQLite query returned:

```text
sqlite-memory-query exit 0 {"answer":42}
```

The helper `audit/runtime-test.py` ran in `sudo -n unshare --net`, with a minimal
explicit environment, isolated HOME and every XDG directory, file credential
storage, no credential variables, and a temporary working directory. No login,
prompt, agent session or cloud integration was invoked. Each architecture's
image produced these literal results:

```text
cursor-agent --version exit 0 2026.10.22-27dcf5f
cursor-agent --help exit 0 Usage: agent [options] [command] [prompt...]
```

The amd64 helper ended `SUMMARY 22 checks; 0 unexpected exits` (including the
expected failing system-Node reproduction). The arm64 helper ended
`SUMMARY 20 checks; 0 unexpected exits`. Full outputs and exits are in
`audit/runtime-results.json` and returned `arm64-evidence/audit/runtime-results.json`.
`logs/image-integrity-amd64.log` additionally records:

```text
node identical to upstream: True mode: 0o755
cursor-agent identical to upstream: True mode: 0o755
cursor-askpass identical to upstream: True mode: 0o755
image alias cursor-agent exit 0 2026.10.22-27dcf5f
image alias agent exit 0 2026.10.22-27dcf5f
```

The helper also found the installed `node-LICENSE.bz2`. Static `readelf -h -d -V`
inspection found both Node binaries require at most GLIBC_2.28; the existing
package-wide glibc bounds were preserved because other packaged binaries also
contribute requirements. Actual addon loading provides stronger evidence on
the tested hosts than those version floors alone.

#### cfn-lint: VERIFIED cause and minimal patches

The [exact 1.58.0 sdist](https://files.pythonhosted.org/packages/10/7e/d9395fa56b9f0f014e9e319daca03dd53133abefc2451b85f06ae4dc61dc/cfn_lint-1.58.0.tar.gz)
and [PyPI metadata](https://pypi.org/pypi/cfn-lint/1.58.0/json) were inspected.
The [upstream test change a0bdcfdf](https://github.com/aws-cloudformation/cfn-lint/commit/a0bdcfdf676997beaf243aff205dd20224a041c3)
([PR 4788](https://github.com/aws-cloudformation/cfn-lint/pull/4788)) adds both
NumberOfAssociations assertions after a live schema refresh. The release also
includes [schema refresh PR 4727](https://github.com/aws-cloudformation/cfn-lint/pull/4727).
Its production schema
[`b16c8a77751b42a5.json`](https://github.com/aws-cloudformation/cfn-lint/blob/v1.58.0/src/cfnlint/data/schemas/resources/b16c8a77751b42a5.json)
already defines this integer property and includes it in `readOnlyProperties`.
However, [`test/unit/conftest.py`](https://github.com/aws-cloudformation/cfn-lint/blob/v1.58.0/test/unit/conftest.py)
switches to offline fixtures without a downloaded schema cache, and its
[`5a9db56d38ad6f4f.json` fixture](https://github.com/aws-cloudformation/cfn-lint/blob/v1.58.0/test/fixtures/schemas/resources/5a9db56d38ad6f4f.json)
lacks both entries. Thus the assertion is correct for this release; the
fallback test schema is stale. The first patch copies only those two entries
from the same release's production schema. All assertions are retained; the
installed runtime schemas and code are unchanged.

The fully offline suite then exposed another test-only issue:
[`test_update_force`](https://github.com/aws-cloudformation/cfn-lint/blob/v1.58.0/test/unit/module/schema/test_manager.py)
mocks archive and metadata requests but leaves the new `version.json` request
in [`ProviderSchemaManager.update()`](https://github.com/aws-cloudformation/cfn-lint/blob/v1.58.0/src/cfnlint/schema/manager.py)
unmocked. With networking unavailable, its last-log assertion saw
`Actual: debug('Could not download version.json')`. The second patch mocks
only that response with `{}`. It preserves the assertions and prevents this
unit test from fetching current schemas or version data during a build.
Neither patch deselects a test. Existing integration/maintenance exclusions
and upstream's `-m not data` selection are unchanged.

Before the fixture patch, targeted runs on all three local Python versions
reported `1 failed, 4 passed`. After both patches, the command
`python3.X -m pytest -o addopts= -q test/unit/module/template/test_getatts.py`
reported:

| Native host / architecture | Python 3.12 | Python 3.13 | Python 3.14 |
| --- | --- | --- | --- |
| leonids-pc / amd64 | `5 passed in 0.01s` | `5 passed in 0.01s` | `5 passed in 0.01s` |
| gentoo / arm64 | `5 passed in 0.02s` | `5 passed in 0.02s` | `5 passed in 0.02s` |

Then `python3.X -m pytest -q test/unit --ignore=test/unit/module/maintenance`
ran on each implementation, using the same isolated HOME/cache, disabled
plugin autoload and network namespace. Final literal suite summaries:

| Native host / architecture | Python | Output |
| --- | --- | --- |
| leonids-pc / amd64 | 3.12 | `5 failed, 3011 passed, 24 subtests passed in 39.15s` |
| leonids-pc / amd64 | 3.13 | `5 failed, 3011 passed, 24 subtests passed in 35.23s` |
| leonids-pc / amd64 | 3.14 | `5 failed, 3011 passed, 24 subtests passed in 37.04s` |
| gentoo / arm64 | 3.12 | `5 failed, 3011 passed, 24 subtests passed in 49.65s` |
| gentoo / arm64 | 3.13 | `5 failed, 3011 passed, 24 subtests passed in 46.42s` |
| gentoo / arm64 | 3.14 | `5 failed, 3011 passed, 24 subtests passed in 45.41s` |

The remaining failures are `TestFormatters::test_junit_formatter`,
`TestFormatters::test_junit_returns_none`, `TestFormatters::test_sarif_formatter`,
`TestTemplate::test_build_graph`, and `TestLintByConfig::test_graph`. Dependency
probes on every implementation on both hosts report `false` for `pydot`,
`junit_xml`, `sarif_om`, and `jschema_to_python`; `defusedxml` is present. The
logs show the corresponding `ModuleNotFoundError` failures. These dependencies
are already declared under `test?`; none was installed. The complete scoped
suite is therefore **NOT VERIFIED as successful**, rather than reported as
passing or hidden by new exclusions. Optional integration behavior remains
blocked until a validation environment supplies those declared dependencies.

#### Actual build/static commands and results

Both packages ran `ebuild <exact-new-ebuild> unpack prepare configure compile
install` through their per-package `audit/build.py` helpers on leonids-pc and
`audit/remote-validation.py` on gentoo. cfn-lint's final local build used
`audit/build-final.py` and a fresh `build-final` directory to apply both patches.
The phase logs record both `Applying ...patch` messages. Build helpers set
Portage temporary, log, dependency-cache, distfile and package-cache paths to
the package workspace. `FEATURES=-test` was used for image creation because
test dependencies were unavailable; the full scoped pytest runs above were
performed separately, not represented as a successful ebuild test phase.

The local build helpers returned `"exit": 0`. Remote logs record:

```text
BUILD dev-util/cursor-agent 0
RUNTIME 0
BUILD dev-python/cfn-lint 0
TEST-RUNNER 0
```

`TEST-RUNNER 0` means its orchestration completed; individual pytest exits
were **1**, as recorded above. The Cursor binary package was unpacked and
staged, not rebuilt from source. cfn-lint produced a pure Python wheel and
staged/byte-compiled it for Python 3.12, 3.13 and 3.14 on each native host.

The following local commands were actually run:

```text
bash -n dev-util/cursor-agent/cursor-agent-2026.10.22.ebuild
bash -n dev-python/cfn-lint/cfn-lint-1.58.0.ebuild
pkgdev manifest -d <Cursor-workspace>/distfiles dev-util/cursor-agent
pkgcheck scan --cache-dir <Cursor-workspace>/cache/pkgcheck dev-util/cursor-agent
pkgcheck scan --cache-dir <cfn-lint-workspace>/cache/pkgcheck dev-python/cfn-lint
git diff --check
```

`git diff --check` exited **0** with no output. Whitespace checks of the two
new patch files produced no diagnostics; both patches were reapplied to fresh
release files, producing byte-identical files to the tested sources. The final
SHA256 comparison against the starting snapshot found only the four existing
files listed above changed, plus the two new patches; `git ls-files --stage`
remained byte-identical to the starting index.

Both syntax commands exited **0** with no output. Manifest generation exited
**0**, printing `* generating manifest: dev-util/cursor-agent::local`.
Both scoped pkgcheck commands exited **0**, with the following findings
(the scans are not described as clean):

```text
dev-util/cursor-agent
  NonsolvableDepsInDev: version 2026.10.22: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.28 ]
  NonsolvableDepsInDev: version 2026.10.22: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
dev-python/cfn-lint
  RedundantVersion: version 1.53.3: slot(0) keywords are overshadowed by version: 1.58.0
```

The musl and retained-old-version findings already appear in the earlier
`upgrade-20261023/logs/static-pkgcheck.log` files. Removing the system Node
requirement removes the former x32 Node-dependency finding; it does not claim
an x32 runtime test. No new pkgcheck finding was introduced. The previous
cfn-lint version remains because optional test coverage is still incomplete.

#### Official guidance, bug history and limits

Consulted current [PMS 9](https://projects.gentoo.org/pms/9/pms.html),
[Devmanual src_prepare/PATCHES guidance](https://devmanual.gentoo.org/ebuild-writing/functions/src_prepare/index.html),
[dependency guidance](https://devmanual.gentoo.org/general-concepts/dependencies/),
[distutils-r1 documentation](https://devmanual.gentoo.org/eclass-reference/distutils-r1.eclass/index.html),
and the local `distutils-r1`, `python-utils-r1`, and `pypi` implementation and
contracts in `/var/db/repos/gentoo/eclass/`. Cursor retains EAPI 9; cfn-lint
retains EAPI 8 as required by its inherited eclasses. The existing inherited
dependency variables, Python implementations, USE behavior and keywords
`~amd64 ~arm64` are preserved. The Gentoo cfn-lint 1.57.1 ebuild was inspected
as prior art; its dependency choices were not used as independent upstream
requirements. No Cursor Agent package was found in the local Gentoo/Guru
searches.

The [Cursor Agent Bugzilla summary query](https://bugs.gentoo.org/rest/bug?summary=cursor-agent&include_fields=id,status,resolution,summary)
found [968806](https://bugs.gentoo.org/968806), **RESOLVED/PKGREMOVED**, about
`--use-system-ca` with an old system Node, and the resolved version-bump report
[974800](https://bugs.gentoo.org/974800). The old-runtime issue reinforces why
launcher/runtime selection must be verified, but does not diagnose this
release's ABI mismatch. The [cfn-lint query](https://bugs.gentoo.org/rest/bug?summary=cfn-lint&include_fields=id,status,resolution,summary)
returned resolved stabilization reports, including [983784](https://bugs.gentoo.org/983784)
(**RESOLVED/FIXED**), and no schema-fixture issue in those results. This search
is not proof that no differently titled bug exists.

**VERIFIED:** amd64 on **leonids-pc** and native arm64 on **gentoo** each
completed non-merging image validation for both packages. All Cursor native
ELF addon files were loaded using matching bundled Node, and offline CLI
help/version worked. cfn-lint's targeted GetAtt tests passed on each declared
Python implementation on both hosts; the broader suite results are quoted
above. Static checks and the preserved-index/unrelated-file comparison were
performed locally.

**INFERRED:** matching the immutable upstream Node binary and its package-local
launchers avoids selecting an incompatible arbitrary system Node on other
machines. The stale offline fixture, rather than the production schema or
assertions, caused the NumberOfAssociations failure; the exact source and
before/after targeted results support that diagnosis.

**NOT VERIFIED:** authenticated Cursor operation, askpass credential exchange,
external services, all application features, musl/x32 execution, and cfn-lint's
five dependency-blocked output integration tests. Neither successful image
staging nor static checks substitute for those runtime/integration tests.
