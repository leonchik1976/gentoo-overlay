# Semgrep 1.185.0 license inspection

The exact release metadata is https://pypi.org/pypi/semgrep/1.185.0/json.
Its Linux wheels declare LGPL-2.1-or-later. The ebuild retains the existing
LGPL-2.1+ declaration and the supplemental dependency grants.

The version-specific notice index extracts the release source notices and
retains the separate fetched component notices during staged installation.
The source is https://github.com/semgrep/semgrep/tree/v1.185.0.
The package workspace retains the fetched artifacts, extraction log, and
native build log for this version.

This is not a complete attestation of the upstream native core's static
link inputs, grammar selection, or corresponding-source/relinking materials.
Those were unresolved in the preceding package and still require upstream
confirmation. The supplementary distribution RPMs provide notices only;
none of their binaries are installed. No SONAME or NEEDED substitution is used.
