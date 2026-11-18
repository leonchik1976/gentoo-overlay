# Semgrep 1.186.0 license inspection

The Linux wheels declare LGPL-2.1-or-later in the
[release metadata](https://pypi.org/pypi/semgrep/1.186.0/json).
The notice index uses the exact
[1.186.0 source tag](https://github.com/semgrep/semgrep/tree/v1.186.0).
The indexed source license texts and semgrep.opam matched 1.185.0 byte
for byte.

For each Linux architecture, the build IDs and SHA-256 hashes of the
.text and .rodata sections matched official AlmaLinux 9.9 and EPEL
RPMs for 25 bundled shared libraries. The notice index uses those package
revisions. The libgcc and libstdc++ RPMs identify the same GCC source RPM.
The glibc notes come from the source RPM identified by the matched
glibc binary RPMs. The RPMs supply documentation during the ebuild.
Only the upstream wheel supplies the installed ELF libraries.

The public build pins tree-sitter 0.26.3. The tree-sitter binary, static
core link inputs, grammar selection and complete corresponding-source
materials still require upstream confirmation.
