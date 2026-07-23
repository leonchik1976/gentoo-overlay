# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Infrastructure as code in any programming language"
HOMEPAGE="
	https://www.pulumi.com/
	https://github.com/pulumi/pulumi
"
SRC_URI="
	amd64? (
		https://github.com/pulumi/pulumi/releases/download/v${PV}/pulumi-v${PV}-linux-x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/pulumi/pulumi/releases/download/v${PV}/pulumi-v${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"

S="${WORKDIR}/pulumi"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

QA_PREBUILT="usr/bin/pulumi*"

src_install() {
	local completion_timeout=60s
	local -x HOME="${T}"
	local -x PULUMI_DISABLE_CI_DETECTION=true
	local -x PULUMI_HOME="${T}"/pulumi-home
	local -x PULUMI_SKIP_UPDATE_CHECK=true
	local -x PULUMI_SUPPRESS_NEO_LINK=true

	# The arm64 binary is significantly slower under Portage's sandbox tracer.
	[[ ${ARCH} == arm64 ]] && completion_timeout=300s

	dobin pulumi pulumi-language-* pulumi-resource-* pulumi-watch

	timeout "${completion_timeout}" ./pulumi gen-completion bash \
		> "${T}"/pulumi.bash-completion ||
		die "Cannot generate bash completions"
	newbashcomp "${T}"/pulumi.bash-completion pulumi

	timeout "${completion_timeout}" ./pulumi gen-completion zsh \
		> "${T}"/pulumi.zsh-completion ||
		die "Cannot generate zsh completions"
	newzshcomp "${T}"/pulumi.zsh-completion _pulumi
}
