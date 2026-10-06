# Traefik binary notices: personal-overlay exception

The `traefik-bin-3.7.14-third-party-notices.tar.xz` resource in
`net-proxy/traefik-bin/files/` is an intentional personal-overlay exception
to Gentoo's recommendation to host large resources as fetched distfiles.
This is not a claim that the bundle meets official-tree size guidance.

The upstream binary embeds dependencies whose notices are not all included
in the release archive. The bundle retains 212 distinct verbatim license and
notice texts obtained from the exact 357 external Go modules identified by
`go version -m -json` for the release binary. It is generated with
`scripts/generate-binary-notices.py`; identical texts are deduplicated.
The release's local `pkg/config/dynamic/ext` module uses the upstream
Traefik license rather than a Go proxy download.

Keeping the archive here makes those notices available during offline
`src_install` without an unpublished maintainer-hosted download URL.
`src_install` extracts the archive and installs the individual notice texts
and index; it does not leave a compressed archive in a docompress directory.
No hosting or publication was authorized or performed. The 64.9 KiB archive
causes `SizeViolation` and `TotalSizeViolation` findings; these are understood
and deliberately left visible, not suppressed. If the maintainer publishes
an immutable copy, use its URL in `SRC_URI`, record its hashes in `Manifest`,
and install the notices from `WORKDIR` instead.

This audit covers Go-module notices. Exhaustive attribution of the embedded
dashboard's JavaScript dependencies remains separate validation work.
