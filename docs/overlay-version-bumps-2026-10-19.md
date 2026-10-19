# Version bumps: 2026-10-19

The Autobahn dependency-floor and aiohttp-retry tagged-source version corrections have fresh build and wheel-metadata validation in [the follow-up report](autobahn-aiohttp-retry-validation-2026-10-19.md). Earlier aiohttp-retry staging did not check its generated wheel version; the follow-up supersedes that coverage.

Bumped 52 packages from /tmp/report.txt and added dev-python/aiohttp-retry, required by Kubernetes. Removed 60 superseded ebuilds and pruned obsolete Manifest records. Old auxiliary resources were retained. The six excluded packages and synchronized Elastic group were unchanged.

No commit, push, branch change, live-system merge or installation was performed.

## VERIFIED: commands and results

Each workspace is /tmp/codex/<category>/<package>-<version>. Logs: final-manifest.log, final-pkgcheck.log, build-amd64.log, stage-amd64.log, build-arm64.log and validation-arm64.json.

Commands: pkgdev manifest -d <workspace>/distfiles <package>; pkgcheck scan --cache-dir <workspace>/pkgcheck-cache <package>; bash -n <ebuild>. Non-merging ebuild phases: unpack prepare configure compile test, followed by install into a temporary image using sudo for ownership. Native arm64 on gentoo used an isolated temporary repository under /tmp/codex and clean unpack prepare configure compile test install. Logs were returned locally and unique remote staging directories removed. No remote checkout was edited.

Binary packages were unpacked/staged, not rebuilt from source. Source packages were compiled. Restricted test phases and offline subsets do not establish full runtime validation.

| Package | Version | amd64 leonids-pc exit | arm64 gentoo exit | Manifest / pkgcheck / syntax exits |
|---|---|---|---|---|
| app-admin/aws-sam-cli | 1.169.0 | 0 | 0 | 0 / 0 / 0 |
| app-admin/aws-vault-bin | 7.17.0 | 0 | 0 | 0 / 0 / 0 |
| app-admin/fluent-bit | 5.1.4 | 0 | 0 | 0 / 0 / 0 |
| app-admin/istioctl-bin | 1.31.2 | 0 | 0 | 0 / 0 / 0 |
| app-admin/kiro-cli-bin | 2.31.1 | 0 | 0 | 0 / 0 / 0 |
| app-admin/pulumi-bin | 3.270.0 | 0 | 0 | 0 / 0 / 0 |
| app-admin/serverless-bin | 4.44.0 | 0 | 0 | 0 / 0 / 0 |
| app-admin/sosreport | 4.12.1 | 0 | 0 | 0 / 0 / 0 |
| app-admin/vault-bin | 2.2.0 | 0 | 0 | 0 / 0 / 0 |
| app-containers/lstk-bin | 1.4.1 | 0 | 0 | 0 / 0 / 0 |
| app-editors/cursor | 3.25.9 | 0 | 0 | 0 / 0 / 0 |
| app-editors/kiro | 1.4.0 | 0 | 0 | 0 / 0 / 0 |
| app-misc/chatgpt-bin | 26.1013.40934 | 0 | 0 | 0 / 0 / 0 |
| app-misc/grok-bot-bin | 0.71.2 | 0 | 0 | 0 / 0 / 0 |
| app-misc/openclaw-bin | 2026.10.5 | 0 | 0 | 0 / 0 / 0 |
| dev-db/aws-dynamodb-local-bin | 3.3.2 | 0 | 0 | 0 / 0 / 0 |
| dev-db/clickhouse-bin | 26.9.22.3 | 0 | 0 | 0 / 0 / 0 |
| dev-db/clickhouse-client-bin | 26.9.22.3 | 0 | 0 | 0 / 0 / 0 |
| dev-db/clickhouse-common-static-bin | 26.9.22.3 | 0 | 0 | 0 / 0 / 0 |
| dev-db/tableplus | 2.0.2_p320 | 0 | 0 | 0 / 0 / 0 |
| dev-perl/Imager | 1.39.0 | 0 | 0 | 0 / 0 / 0 |
| dev-python/autobahn | 26.10.1 | 0 | 0 | 0 / 0 / 0 |
| dev-python/aws-lambda-powertools | 3.36.0 | 0 | 0 | 0 / 0 / 0 |
| dev-python/boto3-stubs | 1.43.114 | 0 | 0 | 0 / 0 / 0 |
| dev-python/botocore-stubs | 1.43.114 | 0 | 0 | 0 / 0 / 0 |
| dev-python/jellyfin-apiclient-python | 1.20.2 | 0 | 0 | 0 / 0 / 0 |
| dev-python/kubernetes | 37.0.1 | 0 | 0 | 0 / 0 / 0 |
| dev-python/mypy-boto3-lambda | 1.43.114 | 0 | 0 | 0 / 0 / 0 |
| dev-python/pipx | 1.18.4 | 0 | 0 | 0 / 0 / 0 |
| dev-python/posthog | 7.72.0 | 0 | 0 | 0 / 0 / 0 |
| dev-python/types-awscrt | 0.37.0 | 0 | 0 | 0 / 0 / 0 |
| dev-python/types-s3transfer | 0.19.2 | 0 | 0 | 0 / 0 / 0 |
| dev-util/cursor-agent | 2026.10.18 | 0 | 0 | 0 / 0 / 0 |
| dev-util/github-copilot-bin | 1.1.30 | 0 | 0 | 0 / 0 / 0 |
| dev-util/github-copilot-cli-bin | 1.0.98 | 0 | 0 | 0 / 0 / 0 |
| dev-util/mise-bin | 2026.10.15 | 0 | 0 | 0 / 0 / 0 |
| dev-util/postman-bin | 12.33.0 | 0 | 0 | 0 / 0 / 0 |
| dev-util/semgrep-bin | 1.181.0 | 0 | 0 | 0 / 0 / 0 |
| dev-util/sonarscanner-bin | 8.2.0.6438 | 0 | 0 | 0 / 0 / 0 |
| dev-util/trivy | 0.76.0 | 0 | 0 | 0 / 0 / 0 |
| mail-client/betterbird-bin | 153.5.0 | 0 | 0 | 0 / 0 / 0 |
| media-sound/lmms | 1.3.0_pre20261019 | 0 | 0 | 0 / 0 / 0 |
| net-analyzer/gsa | 28.6.0 | 0 | 0 | 0 / 0 / 0 |
| net-im/claude-desktop-bin | 2.42304.2 | 0 | 0 | 0 / 0 / 0 |
| net-proxy/traefik-bin | 3.7.15 | 0 | 0 | 0 / 0 / 0 |
| sys-auth/keycloak-bin | 26.8.1 | 0 | 0 | 0 / 0 / 0 |
| sys-cluster/aws-iam-authenticator-bin | 0.7.22 | 0 | 0 | 0 / 0 / 0 |
| sys-cluster/kubescape-bin | 4.0.16 | 0 | 0 | 0 / 0 / 0 |
| sys-process/falco-bin | 0.45.1 | 0 | 0 | 0 / 0 / 0 |
| www-apps/draw-io | 32.5.5 | 0 | 0 | 0 / 0 / 0 |
| www-apps/open-webui-bin | 0.12.3 | 0 | 0 | 0 / 0 / 0 |
| www-client/brave-bin | 1.97.59 | 0 | 0 | 0 / 0 / 0 |
| dev-python/aiohttp-retry | 2.9.1 | 0 | 0 | 0 / 0 / 0 |

## Sources and dependency decisions

[PMS 9](https://projects.gentoo.org/pms/9/pms.html) and [Devmanual EAPI guidance](https://devmanual.gentoo.org/ebuild-writing/eapi/index.html) were consulted alongside current local eclass documentation/implementation and Gentoo/Guru examples. EAPI 9 is current; inherited eclasses requiring EAPI 8 were respected.

SAM translator pin changed to 1.115.0 from [release source](https://github.com/aws/aws-sam-cli/tree/v1.169.0). Kubernetes requires aiohttp-retry; complete [Kubernetes release source](https://github.com/kubernetes-client/python/tree/v37.0.1) supplies test fixtures omitted from its sdist. [aiohttp-retry source](https://github.com/inyutin/aiohttp_retry/tree/v2.9.1) supplies the new dependency. Loopback tests clear inherited proxy settings. Live-cluster tests remain excluded.

Powertools uses hatchling in [release metadata](https://pypi.org/pypi/aws-lambda-powertools/3.36.0/json). Autobahn crypto/CBOR and pipx filelock bounds follow [Autobahn metadata](https://pypi.org/pypi/autobahn/26.10.1/json) and [pipx metadata](https://pypi.org/pypi/pipx/1.18.4/json). Posthog HTTPX compatibility patch was rebased against [exact source](https://github.com/PostHog/posthog-python/tree/posthog-v7.72.0); MCP 2-only tests are gated on SDK major version while SDK 1 tests remain enabled.

OpenClaw runtime lock/license inventory and Open WebUI wheel closure/resolver reports were regenerated, with downloaded-file collision checks and CPU Torch artifacts retained. Inputs are in scripts/locks/. [OpenClaw metadata](https://registry.npmjs.org/openclaw/2026.10.5), [Open WebUI metadata](https://pypi.org/pypi/open-webui/0.12.3/json).

LMMS remains a dated snapshot; exact submodule gitlinks were checked and Qt minimum follows [source](https://github.com/LMMS/lmms/tree/4fde529fb37115c327daadac8506870e92724f3a). Falco notices follow [release source](https://github.com/falcosecurity/falco/releases/tag/0.45.1). Traefik notices were regenerated for 357 modules. Semgrep notices were refreshed, retaining the explicit historical static-provenance limitations; all 26 bundled shared libraries were byte-identical to the previous release on both architectures. [Traefik release](https://github.com/traefik/traefik/releases/tag/v3.7.15), [Semgrep source](https://github.com/semgrep/semgrep/tree/v1.181.0).

Gentoo bug REST responses reported RESOLVED/FIXED for [967367](https://bugs.gentoo.org/967367), Autobahn/txaio removal, and [971387](https://bugs.gentoo.org/971387), pipx removal. Kubernetes bug search found resolved historical [823401](https://bugs.gentoo.org/823401); it does not establish a current-release constraint.

## Release artifact evidence

Exact release URLs recorded during inspection follow. New ebuild SRC_URI and Manifest contain complete architecture/dependency artifact inventories.

- app-admin/aws-sam-cli: [artifact 1](https://files.pythonhosted.org/packages/source/a/aws-sam-cli/aws_sam_cli-1.169.0.tar.gz).
- app-admin/aws-vault-bin: [artifact 1](https://github.com/ByteNess/aws-vault/releases/download/v7.17.0/aws-vault-linux-amd64), [artifact 2](https://github.com/ByteNess/aws-vault/releases/download/v7.17.0/aws-vault-linux-arm64).
- app-admin/fluent-bit: [artifact 1](https://github.com/fluent/fluent-bit/archive/refs/tags/v5.1.4.tar.gz).
- app-admin/istioctl-bin: [artifact 1](https://github.com/istio/istio/releases/download/1.31.2/istioctl-1.31.2-linux-amd64.tar.gz), [artifact 2](https://github.com/istio/istio/releases/download/1.31.2/istioctl-1.31.2-linux-arm64.tar.gz).
- app-admin/kiro-cli-bin: [artifact 1](https://prod.download.cli.kiro.dev/stable/2.31.1/kirocli-x86_64-linux.tar.gz), [artifact 2](https://prod.download.cli.kiro.dev/stable/2.31.1/kirocli-aarch64-linux.tar.gz).
- app-admin/pulumi-bin: [artifact 1](https://github.com/pulumi/pulumi/releases/download/v3.270.0/pulumi-v3.270.0-linux-x64.tar.gz), [artifact 2](https://github.com/pulumi/pulumi/releases/download/v3.270.0/pulumi-v3.270.0-linux-arm64.tar.gz).
- app-admin/serverless-bin: [artifact 1](https://install.serverless.com/archives/serverless-4.44.0.tgz).
- app-admin/sosreport: [artifact 1](https://github.com/sosreport/sos/archive/refs/tags/4.12.1.tar.gz).
- app-admin/vault-bin: [artifact 1](https://releases.hashicorp.com/vault/2.2.0/vault_2.2.0_linux_amd64.zip), [artifact 2](https://releases.hashicorp.com/vault/2.2.0/vault_2.2.0_linux_arm64.zip).
- app-containers/lstk-bin: [artifact 1](https://github.com/localstack/lstk/releases/download/v1.4.1/lstk_1.4.1_linux_amd64.tar.gz), [artifact 2](https://github.com/localstack/lstk/releases/download/v1.4.1/lstk_1.4.1_linux_arm64.tar.gz).
- app-editors/cursor: [artifact 1](https://downloads.cursor.com/production/5d4df965746c5d09740842fc0f1331ba1c15783d/linux/x64/deb/amd64/deb/cursor_3.25.9_amd64.deb), [artifact 2](https://downloads.cursor.com/production/5d4df965746c5d09740842fc0f1331ba1c15783d/linux/arm64/deb/arm64/deb/cursor_3.25.9_arm64.deb).
- app-editors/kiro: [artifact 1](https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.4.0/deb/kiro-ide-1.4.0-stable-linux-x64.deb), [artifact 2](https://prod.download.desktop.kiro.dev/releases/stable/linux-arm64/signed/1.4.0/deb/kiro-ide-1.4.0-stable-linux-arm64.deb).
- app-misc/chatgpt-bin: [artifact 1](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.1013.40934_amd64.deb), [artifact 2](https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.1013.40934_arm64.deb).
- app-misc/grok-bot-bin: [artifact 1](https://downloads.cursor.com/grokbot/stable/92808c0ad869b2e3725dbc3b8fa2fcc991687502/linux/x64/grok-bot_0.71.2_amd64.deb), [artifact 2](https://downloads.cursor.com/grokbot/stable/92808c0ad869b2e3725dbc3b8fa2fcc991687502/linux/arm64/grok-bot_0.71.2_arm64.deb).
- app-misc/openclaw-bin: [artifact 1](../app-misc/openclaw-bin/openclaw-bin-2026.10.5.ebuild).
- dev-db/aws-dynamodb-local-bin: [artifact 1](https://d1ni2b6xgvw0s0.cloudfront.net/v2.x/dynamodb_local_latest.tar.gz).
- dev-db/clickhouse-bin: [artifact 1](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-server-26.9.22.3-amd64.tgz), [artifact 2](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-server-26.9.22.3-arm64.tgz).
- dev-db/clickhouse-client-bin: [artifact 1](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-client-26.9.22.3-amd64.tgz), [artifact 2](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-client-26.9.22.3-arm64.tgz).
- dev-db/clickhouse-common-static-bin: [artifact 1](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-common-static-26.9.22.3-amd64.tgz), [artifact 2](https://github.com/ClickHouse/ClickHouse/releases/download/v26.9.22.3-stable/clickhouse-common-static-26.9.22.3-arm64.tgz).
- dev-db/tableplus: [artifact 1](https://deb.tableplus.com/debian/26/pool/main/t/tableplus/tableplus_2.0.2-320_amd64.deb), [artifact 2](https://deb.tableplus.com/debian/26-arm/pool/main/t/tableplus/tableplus_2.0.2-320_arm64.deb).
- dev-perl/Imager: [artifact 1](https://cpan.metacpan.org/authors/id/T/TO/TONYC/Imager-1.039.tar.gz).
- dev-python/autobahn: [artifact 1](https://files.pythonhosted.org/packages/source/a/autobahn/autobahn-26.10.1.tar.gz).
- dev-python/aws-lambda-powertools: [artifact 1](https://files.pythonhosted.org/packages/source/a/aws-lambda-powertools/aws_lambda_powertools-3.36.0.tar.gz).
- dev-python/boto3-stubs: [artifact 1](https://files.pythonhosted.org/packages/source/b/boto3-stubs/boto3_stubs-1.43.114.tar.gz).
- dev-python/botocore-stubs: [artifact 1](https://files.pythonhosted.org/packages/source/b/botocore-stubs/botocore_stubs-1.43.114.tar.gz).
- dev-python/jellyfin-apiclient-python: [artifact 1](https://files.pythonhosted.org/packages/source/j/jellyfin-apiclient-python/jellyfin_apiclient_python-1.20.2.tar.gz).
- dev-python/kubernetes: [artifact 1](https://github.com/kubernetes-client/python/archive/refs/tags/v37.0.1.tar.gz).
- dev-python/mypy-boto3-lambda: [artifact 1](https://files.pythonhosted.org/packages/source/m/mypy-boto3-lambda/mypy_boto3_lambda-1.43.114.tar.gz).
- dev-python/pipx: [artifact 1](https://github.com/pypa/pipx/archive/1.18.4.tar.gz).
- dev-python/posthog: [artifact 1](https://github.com/PostHog/posthog-python/archive/refs/tags/posthog-v7.72.0.tar.gz).
- dev-python/types-awscrt: [artifact 1](https://files.pythonhosted.org/packages/source/t/types-awscrt/types_awscrt-0.37.0.tar.gz).
- dev-python/types-s3transfer: [artifact 1](https://files.pythonhosted.org/packages/source/t/types-s3transfer/types_s3transfer-0.19.2.tar.gz).
- dev-util/cursor-agent: [artifact 1](https://downloads.cursor.com/lab/2026.10.18-ea085cb/linux/x64/agent-cli-package.tar.gz), [artifact 2](https://downloads.cursor.com/lab/2026.10.18-ea085cb/linux/arm64/agent-cli-package.tar.gz).
- dev-util/github-copilot-bin: [artifact 1](https://github.com/github/app/releases/download/v1.1.30/GitHub-Copilot-linux-x64.deb), [artifact 2](https://github.com/github/app/releases/download/v1.1.30/GitHub-Copilot-linux-arm64.deb).
- dev-util/github-copilot-cli-bin: [artifact 1](https://github.com/github/copilot-cli/releases/download/v1.0.98/copilot-linux-x64.tar.gz), [artifact 2](https://github.com/github/copilot-cli/releases/download/v1.0.98/copilot-linux-arm64.tar.gz).
- dev-util/mise-bin: [artifact 1](https://github.com/jdx/mise/releases/download/v2026.10.15/mise-v2026.10.15-linux-x64.tar.gz), [artifact 2](https://github.com/jdx/mise/releases/download/v2026.10.15/mise-v2026.10.15-linux-arm64.tar.gz).
- dev-util/postman-bin: [artifact 1](https://dl.pstmn.io/download/version/12.33.0/linux64), [artifact 2](https://dl.pstmn.io/download/version/12.33.0/linux_arm64).
- dev-util/semgrep-bin: [artifact 1](../dev-util/semgrep-bin/semgrep-bin-1.181.0.ebuild).
- dev-util/sonarscanner-bin: [artifact 1](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.2.0.6438.zip).
- dev-util/trivy: [artifact 1](https://github.com/aquasecurity/trivy/releases/download/v0.76.0/trivy_0.76.0_Linux-64bit.tar.gz), [artifact 2](https://github.com/aquasecurity/trivy/releases/download/v0.76.0/trivy_0.76.0_Linux-ARM64.tar.gz).
- mail-client/betterbird-bin: [artifact 1](https://www.betterbird.eu/downloads/LinuxArchive/betterbird-153.5.0esr-bb11.en-US.linux-x86_64.tar.xz), [artifact 2](https://www.betterbird.eu/downloads/LinuxArchive/betterbird-153-linux-aarch64-built-with-glibc-2_36/betterbird-153.5.0esr-bb11.en-US.linux-aarch64.tar.xz).
- media-sound/lmms: [artifact 1](../media-sound/lmms/lmms-1.3.0_pre20261019.ebuild).
- net-analyzer/gsa: [artifact 1](../net-analyzer/gsa/gsa-28.6.0.ebuild).
- net-im/claude-desktop-bin: [artifact 1](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_2.42304.2_amd64.deb), [artifact 2](https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_2.42304.2_arm64.deb).
- net-proxy/traefik-bin: [artifact 1](../net-proxy/traefik-bin/traefik-bin-3.7.15.ebuild).
- sys-auth/keycloak-bin: [artifact 1](https://github.com/keycloak/keycloak/releases/download/26.8.1/keycloak-26.8.1.tar.gz).
- sys-cluster/aws-iam-authenticator-bin: [artifact 1](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.7.22/aws-iam-authenticator_0.7.22_linux_amd64), [artifact 2](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.7.22/aws-iam-authenticator_0.7.22_linux_arm64).
- sys-cluster/kubescape-bin: [artifact 1](https://github.com/kubescape/kubescape/releases/download/v4.0.16/kubescape_4.0.16_linux_amd64.tar.gz), [artifact 2](https://github.com/kubescape/kubescape/releases/download/v4.0.16/kubescape_4.0.16_linux_arm64.tar.gz).
- sys-process/falco-bin: [artifact 1](https://download.falco.org/packages/bin/x86_64/falco-0.45.1-x86_64.tar.gz), [artifact 2](https://download.falco.org/packages/bin/aarch64/falco-0.45.1-aarch64.tar.gz).
- www-apps/draw-io: [artifact 1](https://github.com/jgraph/drawio/archive/refs/tags/v32.5.5.tar.gz).
- www-apps/open-webui-bin: [artifact 1](../www-apps/open-webui-bin/open-webui-bin-0.12.3.ebuild).
- www-client/brave-bin: [artifact 1](https://github.com/brave/brave-browser/releases/download/v1.97.59/brave-browser_1.97.59_amd64.deb), [artifact 2](https://github.com/brave/brave-browser/releases/download/v1.97.59/brave-browser_1.97.59_arm64.deb).
- dev-python/aiohttp-retry: [artifact 1](https://files.pythonhosted.org/packages/9d/61/ebda4d8e3d8cfa1fd3db0fb428db2dd7461d5742cea35178277ad180b033/aiohttp_retry-2.9.1.tar.gz).

## Literal pkgcheck output

Exit 0 does not mean no findings. Warnings remain visible without suppression.

### app-admin/kiro-cli-bin

```text
app-admin/kiro-cli-bin
  RequiredUseDefaults: version 2.31.1: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.31.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### app-admin/pulumi-bin

```text
app-admin/pulumi-bin
  NonsolvableDepsInDev: version 3.270.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  RequiredUseDefaults: version 3.270.0: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 3.270.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### app-admin/serverless-bin

```text
app-admin/serverless-bin
  NonsolvableDepsInDev: version 4.44.0: nonsolvable depset(bdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-18.17.0 ]
  NonsolvableDepsInDev: version 4.44.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-18.17.0[ssl] ]
```

### app-editors/cursor

```text
app-editors/cursor
  NonsolvableDepsInDev: version 3.25.9: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
```

### app-editors/kiro

```text
app-editors/kiro
  NonsolvableDepsInDev: version 1.4.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.34 ]
  NonsolvableDepsInDev: version 1.4.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.28 ]
  RequiredUseDefaults: version 1.4.0: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.4.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### app-misc/chatgpt-bin

```text
app-misc/chatgpt-bin
  NonsolvableDepsInDev: version 26.1013.40934: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.30 ]
  RequiredUseDefaults: version 26.1013.40934: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 26.1013.40934: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### app-misc/grok-bot-bin

```text
app-misc/grok-bot-bin
  NonsolvableDepsInDev: version 0.71.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.38 ]
```

### app-misc/openclaw-bin

```text
app-misc/openclaw-bin
  NonsolvableDepsInDev: version 2026.10.5: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.10.5: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ <net-libs/nodejs-25, >=net-libs/nodejs-24.16.0, >=net-libs/nodejs-26.1.0 ]
  RequiredUseDefaults: version 2026.10.5: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.5: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-db/clickhouse-common-static-bin

```text
dev-db/clickhouse-common-static-bin
  NonsolvableDepsInDev: version 26.9.22.3: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.17 ]
  RequiredUseDefaults: version 26.9.22.3: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 26.9.22.3: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-db/tableplus

```text
dev-db/tableplus
  RequiredUseDefaults: version 2.0.2_p320: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2.0.2_p320: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-python/botocore-stubs

```text
dev-python/botocore-stubs
  PythonCompatUpdate: version 1.43.114: PYTHON_COMPAT update available: python3_15
```

### dev-python/types-s3transfer

```text
dev-python/types-s3transfer
  PythonCompatUpdate: version 0.19.2: PYTHON_COMPAT update available: python3_15
```

### dev-util/cursor-agent

```text
dev-util/cursor-agent
  NonsolvableDepsInDev: version 2026.10.18: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ sys-libs/glibc ]
  NonsolvableDepsInDev: version 2026.10.18: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/x32): solutions: [ >=net-libs/nodejs-22.1.0 ]
```

### dev-util/github-copilot-bin

```text
dev-util/github-copilot-bin
  RequiredUseDefaults: version 1.1.30: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.1.30: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-util/github-copilot-cli-bin

```text
dev-util/github-copilot-cli-bin
  NonsolvableDepsInDev: version 1.0.98: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
  RequiredUseDefaults: version 1.0.98: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.0.98: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-util/mise-bin

```text
dev-util/mise-bin
  RequiredUseDefaults: version 2026.10.15: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 2026.10.15: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-util/postman-bin

```text
dev-util/postman-bin
  NonsolvableDepsInDev: version 12.33.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.34 ]
```

### dev-util/semgrep-bin

```text
dev-util/semgrep-bin
  TotalSizeViolation: files/ directory exceeds 50.0 KiB in size; 58.7 KiB total
  BetterCompressionUri: version 1.181.0: line 51: better compression URI using extension '.tar.bz2' for 'https://gitlab.inria.fr/fpottier/menhir/-/archive/20230608/archive.tar.gz'
  NonexistentBlocker: version 1.181.0: nonexistent blocker RDEPEND="!dev-util/semgrep": no matches in repo history
  NonexistentBlocker: version 1.181.0: nonexistent blocker RDEPEND="!dev-util/semgrep-core": no matches in repo history
  NonsolvableDepsInDev: version 1.181.0: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.35 ]
  RequiredUseDefaults: version 1.181.0: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.181.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### mail-client/betterbird-bin

```text
mail-client/betterbird-bin
  NonsolvableDepsInDev: version 153.5.0: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/musl) (3 total): solutions: [ >=sys-libs/glibc-2.28 ]
  RequiredUseDefaults: version 153.5.0: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 153.5.0: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### media-sound/lmms

```text
media-sound/lmms
  NonsolvableDepsInDev: version 1.3.0_pre20261019: nonsolvable depset(depend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (9 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInDev: version 1.3.0_pre20261019: nonsolvable depset(rdepend) keyword(~arm64) dev profile (default/linux/arm64/23.0/hardened) (9 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInStable: version 1.3.0_pre20261019: nonsolvable depset(depend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (12 total): solutions: [ media-libs/libgig, media-libs/stk ]
  NonsolvableDepsInStable: version 1.3.0_pre20261019: nonsolvable depset(rdepend) keyword(~arm64) stable profile (default/linux/arm64/23.0) (12 total): solutions: [ media-libs/libgig, media-libs/stk ]
```

### net-im/claude-desktop-bin

```text
net-im/claude-desktop-bin
  NonsolvableDepsInDev: version 2.42304.2: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.34 ]
```

### net-proxy/traefik-bin

```text
net-proxy/traefik-bin
  SizeViolation: 'files/traefik-bin-3.7.14-third-party-notices.tar.xz' exceeds 20.0 KiB in size; 64.9 KiB total
  SizeViolation: 'files/traefik-bin-3.7.15-third-party-notices.tar.xz' exceeds 20.0 KiB in size; 65.0 KiB total
  TotalSizeViolation: files/ directory exceeds 50.0 KiB in size; 130.7 KiB total
```

### sys-auth/keycloak-bin

```text
sys-auth/keycloak-bin
  RequiredUseDefaults: version 26.8.1: profile: 'default/linux/amd64/23.0' (53 total) failed REQUIRED_USE: exactly-one-of ( h2-file h2-mem mariadb mssql mysql postgres )
```

### sys-process/falco-bin

```text
sys-process/falco-bin
  RequiredUseDefaults: version 0.45.1: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 0.45.1: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### www-apps/open-webui-bin

```text
www-apps/open-webui-bin
  NonsolvableDepsInDev: version 0.12.3: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.28 ]
  PythonCompatUpdate: version 0.12.3: PYTHON_COMPAT updates available: python3_13, python3_14, python3_15
  RequiredUseDefaults: version 0.12.3: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 0.12.3: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### www-client/brave-bin

```text
www-client/brave-bin
  NonsolvableDepsInDev: version 1.97.59: nonsolvable depset(rdepend) keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total): solutions: [ >=sys-libs/glibc-2.25 ]
  RequiredUseDefaults: version 1.97.59: profile: 'default/linux/amd64/23.0/musl' (6 total) failed REQUIRED_USE: elibc_glibc
  RequiredUseUnsatisfiableInDev: version 1.97.59: REQUIRED_USE can't be satisfied due to masked/forced USE flags, keyword(~amd64) dev profile (default/linux/amd64/23.0/musl) (6 total)
```

### dev-python/aiohttp-retry

```text
dev-python/aiohttp-retry
  PythonCompatUpdate: version 2.9.1: PYTHON_COMPAT update available: python3_15
```

## NOT VERIFIED

No live deployment, graphical application session, or full runtime integration was performed. Only tested host configurations are covered, not every USE/Python combination. Missing declared test dependencies were supplied as SHA256-checked upstream wheels extracted under temporary PYTHONPATH paths, without installing them. Existing downstream compatibility adjustments and Semgrep static component provenance remain limitations. Nonzero architecture results in the table remain unresolved.

## Literal test summaries

dev-python/autobahn amd64:

```text
======================== 35 passed, 1 warning in 1.72s =========================
======================== 35 passed, 1 warning in 1.72s =========================
============================== 35 passed in 1.72s ==============================
```

dev-python/autobahn arm64:

```text
======================== 35 passed, 1 warning in 1.77s =========================
======================== 35 passed, 1 warning in 1.76s =========================
============================== 35 passed in 1.75s ==============================
```

dev-python/kubernetes amd64:

```text
======= 444 passed, 12 warnings, 174 subtests passed in 81.97s (0:01:21) =======
======= 444 passed, 12 warnings, 174 subtests passed in 82.30s (0:01:22) =======
= 442 passed, 2 deselected, 13 warnings, 174 subtests passed in 82.64s (0:01:22) =
```

dev-python/kubernetes arm64:

```text
======= 444 passed, 12 warnings, 174 subtests passed in 82.15s (0:01:22) =======
======= 444 passed, 12 warnings, 174 subtests passed in 81.05s (0:01:21) =======
= 442 passed, 2 deselected, 13 warnings, 174 subtests passed in 83.02s (0:01:23) =
```

dev-python/posthog amd64:

```text
= 3691 passed, 2 skipped, 22 deselected, 166 warnings, 42 subtests passed in 73.93s (0:01:13) =
============================== 54 passed in 0.46s ==============================
= 3691 passed, 2 skipped, 22 deselected, 166 warnings, 42 subtests passed in 73.49s (0:01:13) =
============================== 54 passed in 0.50s ==============================
= 3691 passed, 2 skipped, 22 deselected, 173 warnings, 42 subtests passed in 75.50s (0:01:15) =
============================== 54 passed in 0.51s ==============================
```

dev-python/posthog arm64:

```text
= 3691 passed, 2 skipped, 22 deselected, 166 warnings, 42 subtests passed in 126.85s (0:02:06) =
============================== 54 passed in 0.58s ==============================
= 3691 passed, 2 skipped, 22 deselected, 166 warnings, 42 subtests passed in 126.62s (0:02:06) =
============================== 54 passed in 0.54s ==============================
= 3691 passed, 2 skipped, 22 deselected, 173 warnings, 42 subtests passed in 127.67s (0:02:07) =
============================== 54 passed in 0.56s ==============================
```

dev-python/aiohttp-retry amd64:

```text
======================= 42 passed, 3 warnings in 17.00s ========================
======================= 42 passed, 3 warnings in 17.00s ========================
======================= 42 passed, 3 warnings in 16.99s ========================
```

dev-python/aiohttp-retry arm64:

```text
======================= 42 passed, 3 warnings in 17.39s ========================
======================= 42 passed, 3 warnings in 17.33s ========================
======================= 42 passed, 3 warnings in 17.41s ========================
```

media-sound/lmms amd64:

```text
100% tests passed, 0 tests failed out of 8
```

media-sound/lmms arm64:

```text
100% tests passed, 0 tests failed out of 8
```

Metadata-only follow-ups after build validation: explicit glibc floors from the downloaded TablePlus (>=2.35) and Brave (>=2.25) Debian control records; Autobahn history comment simplified. Scoped QA was repeated for those edits. No new architecture build was claimed for comment-only or dependency-floor changes.

Files changed comprise the package ebuilds and Manifests listed above; new aiohttp-retry metadata; regenerated OpenClaw license inventory/runtime lock; Open WebUI resolver reports; Semgrep audit/notice index; Traefik notice archive; rebased Posthog patch; and this report. Auxiliary old resources were retained intentionally.
