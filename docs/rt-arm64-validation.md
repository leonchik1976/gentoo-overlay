# RT arm64 dependency keywords

RT 5.0.10-r1 deliberately has `KEYWORDS="~amd64 ~arm64"` in this personal overlay.
Native arm64 validation uses `gentoo`; amd64 validation uses `server01`.

## VERIFIED: QA findings

`pkgcheck scan www-apps/rt` reports `NonsolvableDepsInDev` and
`NonsolvableDepsInStable` for `~arm64`. These are dependency keyword gaps in the
available repositories, not a finding that RT's Perl code is architecture-specific.
The affected dependency atoms reported across dependency/USE combinations are:

- `>=dev-perl/Apache-Session-1.530.0`
- `>=dev-perl/CSS-Squish-0.60.0`
- `>=dev-perl/DBIx-SearchBuilder-1.800.0`
- `>=dev-perl/Date-Extract-0.70.0`
- `>=dev-perl/Email-Address-List-0.60.0`
- `>=dev-perl/Module-Versions-Report-1.50.0`
- `>=dev-perl/Role-Basic-0.120.0`
- `>=dev-perl/Symbol-Global-Name-0.50.0`
- `>=dev-perl/Text-Quoted-2.80.0`
- `>=dev-perl/Text-WikiFormat-0.760.0`
- `>=dev-perl/Tree-Simple-1.40.0`
- `>=www-apache/mod_perl-2`
- `dev-perl/Apache-DBI`
- `dev-perl/Business-Hours`
- `dev-perl/CGI-PSGI`
- `dev-perl/CSS-Minifier-XS`
- `dev-perl/Convert-Color`
- `dev-perl/Crypt-Eksblowfish`
- `dev-perl/Crypt-X509`
- `dev-perl/Data-GUID`
- `dev-perl/Data-ICal`
- `dev-perl/Data-Page`
- `dev-perl/GnuPG-Interface`
- `dev-perl/GraphViz2`
- `dev-perl/HTML-FormatExternal`
- `dev-perl/HTML-FormatText-WithLinks`
- `dev-perl/HTML-FormatText-WithLinks-AndTables`
- `dev-perl/HTML-Gumbo`
- `dev-perl/HTML-Mason`
- `dev-perl/HTML-Mason-PSGIHandler`
- `dev-perl/HTML-Quoted`
- `dev-perl/HTML-RewriteAttributes`
- `dev-perl/JavaScript-Minifier-XS`
- `dev-perl/Locale-Maketext-Fuzzy`
- `dev-perl/MooseX-NonMoose`
- `dev-perl/Path-Dispatcher`
- `dev-perl/PerlIO-eol`
- `dev-perl/Regexp-Common-net-CIDR`
- `dev-perl/Scope-Upper`
- `dev-perl/Starlet`
- `dev-perl/Text-Password-Pronounceable`
- `dev-perl/Text-WordDiff`
- `dev-perl/Text-Wrapper`
- `dev-perl/Time-ParseDate`
- `dev-perl/Web-Machine`
- `www-servers/spawn-fcgi`

Some entries apply only to apache, graphviz or nginx configurations. They are
not all required by every installation. No dependency was removed to hide the
findings, and no untested dependency keywords were added to other packages.

## Local deployment

Administrators must resolve Portage's actual selected dependency graph against
their own profile and USE flags. Packages lacking an arm64 keyword require an
explicit local `package.accept_keywords` entry using `**` only where needed;
packages already keyworded `~arm64` need normal unstable keyword acceptance.
The complete scan list above is not a blanket keyword-override recommendation.
This is an intentional personal-overlay workflow, not Gentoo keywording policy.

## VERIFIED: image-only validation

Both hosts completed configure/compile and installation into the temporary
Portage image. RT's compile phase is a no-op; configure and upstream dependency
checks are the meaningful build steps. Logs include:

```
All dependencies found.
>>> Completed installing www-apps/rt-5.0.10-r1 into /tmp/codex/www-apps/rt-5.0.10/portage/www-apps/rt-5.0.10-r1/image
```

The install phase was rerun with `sudo -n env PORTAGE_TMPDIR=... ebuild ... install`
to allow `install -o rt -g rt` inside the temporary image. No package was merged,
no RT database was initialized, and no service was started. Remote work stayed
under `/tmp/codex/www-apps/rt-5.0.10`; the remote overlay checkout was not edited.

## Tests and limits

The upstream test suite is not run (`RESTRICT="test"`), because it needs a test
RT database and an isolated configured application. Image completion is build
validation, not an application integration test. Keyword QA findings remain
visible and are documented rather than suppressed.

Sources: [Portage keyword acceptance](https://dev.gentoo.org/~zmedico/portage/doc/man/portage.5.html),
[RT 5.0.10 upstream artifact](https://download.bestpractical.com/pub/rt/release/rt-5.0.10.tar.gz),
`www-apps/rt/rt-5.0.10-r1.ebuild`, and `pkgcheck` output from 2026-10-04.

## 2026-10-04: RT 6 dependency exceptions

VERIFIED: the six-package scoped scan (`www-apps/rt`, `app-misc/openclaw-bin`, and the four new Perl support packages) returned exit 0, with `NonsolvableDepsInDev` and `NonsolvableDepsInStable` findings. Across all tested USE combinations it names **51 dependency atoms without any matching arm64-keyworded ebuild** in the available Gentoo/GURU/local repositories. Metadata evidence is `/tmp/codex/overlay-upgrades-20261004/arm64-exceptions.json`; literal scan output is `pkgcheck-followup.log` in that directory. This is a scan with findings, not a clean result.

These are explicit personal-overlay exceptions: RT 6.0.3, Hash-Merge-Extra 0.60.0 and DBIx-SearchBuilder 1.850.0 retain their requested `~arm64` declarations despite unsatisfied repository dependency keywords. Their declarations do not grant arm64 keywords to dependencies and do not make an ordinary Portage dependency resolution succeed. No keyword overrides or masks were changed, and no missing dependencies were installed on a live system. Dependency image tests do not establish Gentoo keyword coverage or stabilization.

RT’s graphviz, web-server and FastCGI alternatives account for some atoms below; not every atom applies to every USE configuration. Hash-Merge-Extra additionally needs unkeyworded Hash-Merge; DBIx-SearchBuilder additionally needs the five unkeyworded packages shown under its consumer column. Transitive gaps can extend beyond this direct list.

VERIFIED: File-Which is available as `dev-perl/File-Which-1.270.0-r1` in [File-Which-1.270.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/File-Which/File-Which-1.270.0-r1.ebuild), whose literal KEYWORDS include stable `amd64 arm64`. Adding RT’s declared dependency on File-Which therefore introduces no arm64 keyword exception. The need is independently established by `etc/cpanfile` and the imports in `lib/RT/Crypt/GnuPG.pm` and `lib/RT/Crypt/SMIME.pm` from [RT’s exact 6.0.3 source](https://download.bestpractical.com/pub/rt/release/rt-6.0.3.tar.gz).

Current direct keyword exceptions (exact matching ebuild paths and KEYWORDS, not assertions about upstream architecture support):

| Required atom | Consumers | Matching ebuild evidence | KEYWORDS |
|---|---|---|---|
| `>=dev-perl/Apache-Session-1.530.0` | `www-apps/rt` | [Apache-Session-1.940.0.ebuild](/var/db/repos/gentoo/dev-perl/Apache-Session/Apache-Session-1.940.0.ebuild) | `~alpha amd64 ppc ~riscv x86` |
| `>=dev-perl/CSS-Squish-0.60.0` | `www-apps/rt` | [CSS-Squish-0.100.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/CSS-Squish/CSS-Squish-0.100.0-r2.ebuild) | `amd64 ~ppc ~riscv ~x86` |
| `>=dev-perl/Cache-Simple-TimedExpiry-0.210.0` | `dev-perl/DBIx-SearchBuilder` | [Cache-Simple-TimedExpiry-0.270.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Cache-Simple-TimedExpiry/Cache-Simple-TimedExpiry-0.270.0-r2.ebuild) | `~alpha amd64 ~hppa ppc ~riscv ~sparc x86` |
| `>=dev-perl/Class-ReturnValue-0.400.0` | `dev-perl/DBIx-SearchBuilder` | [Class-ReturnValue-0.550.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Class-ReturnValue/Class-ReturnValue-0.550.0-r2.ebuild) | `~alpha amd64 ~hppa ppc ~riscv ~sparc x86` |
| `>=dev-perl/Date-Extract-0.70.0` | `www-apps/rt` | [Date-Extract-0.70.0.ebuild](/var/db/repos/gentoo/dev-perl/Date-Extract/Date-Extract-0.70.0.ebuild) | `amd64 ~riscv` |
| `>=dev-perl/Email-Address-List-0.60.0` | `www-apps/rt` | [Email-Address-List-0.60.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Email-Address-List/Email-Address-List-0.60.0-r2.ebuild) | `amd64 ~riscv` |
| `>=dev-perl/Module-Versions-Report-1.50.0` | `www-apps/rt` | [Module-Versions-Report-1.60.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Module-Versions-Report/Module-Versions-Report-1.60.0-r2.ebuild) | `amd64 ~ppc ~riscv x86` |
| `>=dev-perl/Path-Dispatcher-1.70.0` | `www-apps/rt` | [Path-Dispatcher-1.80.0.ebuild](/var/db/repos/gentoo/dev-perl/Path-Dispatcher/Path-Dispatcher-1.80.0.ebuild) | `~amd64 ~x86` |
| `>=dev-perl/Role-Basic-0.120.0` | `www-apps/rt` | [Role-Basic-0.160.0.ebuild](/var/db/repos/gentoo/dev-perl/Role-Basic/Role-Basic-0.160.0.ebuild) | `amd64 ~arm ~hppa ppc ~riscv x86` |
| `>=dev-perl/Symbol-Global-Name-0.50.0` | `www-apps/rt` | [Symbol-Global-Name-0.50.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Symbol-Global-Name/Symbol-Global-Name-0.50.0-r1.ebuild) | `amd64 ~riscv` |
| `>=dev-perl/Text-Quoted-2.80.0` | `www-apps/rt` | [Text-Quoted-2.100.0.ebuild](/var/db/repos/gentoo/dev-perl/Text-Quoted/Text-Quoted-2.100.0.ebuild) | `amd64 ~ppc ~riscv ~sparc x86` |
| `>=dev-perl/Text-WikiFormat-0.760.0` | `www-apps/rt` | [Text-WikiFormat-0.810.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Text-WikiFormat/Text-WikiFormat-0.810.0-r1.ebuild) | `amd64 ~ppc ~riscv x86` |
| `>=dev-perl/Tree-Simple-1.40.0` | `www-apps/rt` | [Tree-Simple-1.340.0.ebuild](/var/db/repos/gentoo/dev-perl/Tree-Simple/Tree-Simple-1.340.0.ebuild) | `amd64 ~ppc ~riscv x86` |
| `>=dev-perl/Web-Machine-0.120.0` | `www-apps/rt` | [Web-Machine-0.170.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Web-Machine/Web-Machine-0.170.0-r1.ebuild) | `~amd64 ~x86` |
| `>=dev-perl/capitalization-0.30.0` | `dev-perl/DBIx-SearchBuilder` | [capitalization-0.30.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/capitalization/capitalization-0.30.0-r2.ebuild) | `~alpha amd64 ~hppa ppc ~riscv ~sparc x86` |
| `>=www-apache/mod_perl-2` | `www-apps/rt` | [mod_perl-2.0.13-r2.ebuild](/var/db/repos/gentoo/www-apache/mod_perl/mod_perl-2.0.13-r2.ebuild) | `~amd64 ~arm ~ppc ~ppc64 ~riscv ~x86` |
| `dev-perl/Apache-DBI` | `www-apps/rt` | [Apache-DBI-1.120.0-r3.ebuild](/var/db/repos/gentoo/dev-perl/Apache-DBI/Apache-DBI-1.120.0-r3.ebuild) | `~alpha amd64 ppc ppc64 ~riscv x86` |
| `dev-perl/Business-Hours` | `www-apps/rt` | [Business-Hours-0.130.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Business-Hours/Business-Hours-0.130.0-r1.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/CGI-PSGI` | `www-apps/rt` | [CGI-PSGI-0.150.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/CGI-PSGI/CGI-PSGI-0.150.0-r2.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/CSS-Minifier-XS` | `www-apps/rt` | [CSS-Minifier-XS-0.140.0.ebuild](/var/db/repos/gentoo/dev-perl/CSS-Minifier-XS/CSS-Minifier-XS-0.140.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Convert-Color` | `www-apps/rt` | [Convert-Color-0.180.0.ebuild](/var/db/repos/gentoo/dev-perl/Convert-Color/Convert-Color-0.180.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Crypt-Eksblowfish` | `www-apps/rt` | [Crypt-Eksblowfish-0.9.0-r4.ebuild](/var/db/repos/gentoo/dev-perl/Crypt-Eksblowfish/Crypt-Eksblowfish-0.9.0-r4.ebuild) | `amd64 ~riscv` |
| `dev-perl/Crypt-X509` | `www-apps/rt` | [Crypt-X509-0.550.0.ebuild](/var/db/repos/gentoo/dev-perl/Crypt-X509/Crypt-X509-0.550.0.ebuild) | `amd64 ~riscv` |
| `dev-perl/DBIx-DBSchema` | `dev-perl/DBIx-SearchBuilder` | [DBIx-DBSchema-0.470.0.ebuild](/var/db/repos/gentoo/dev-perl/DBIx-DBSchema/DBIx-DBSchema-0.470.0.ebuild) | `amd64 ~hppa ppc ~riscv x86` |
| `dev-perl/Data-GUID` | `www-apps/rt` | [Data-GUID-0.51.0.ebuild](/var/db/repos/gentoo/dev-perl/Data-GUID/Data-GUID-0.51.0.ebuild) | `amd64 ~riscv` |
| `dev-perl/Data-ICal` | `www-apps/rt` | [Data-ICal-0.240.0.ebuild](/var/db/repos/gentoo/dev-perl/Data-ICal/Data-ICal-0.240.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Data-Page` | `www-apps/rt` | [Data-Page-2.30.0.ebuild](/var/db/repos/gentoo/dev-perl/Data-Page/Data-Page-2.30.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/DateTime-Set` | `www-apps/rt` | [DateTime-Set-0.390.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/DateTime-Set/DateTime-Set-0.390.0-r2.ebuild) | `amd64 ~riscv x86` |
| `dev-perl/GnuPG-Interface` | `www-apps/rt` | [GnuPG-Interface-1.70.0.ebuild](/var/db/repos/gentoo/dev-perl/GnuPG-Interface/GnuPG-Interface-1.70.0.ebuild) | `amd64 ~arm ~hppa ppc ~riscv x86` |
| `dev-perl/GraphViz2` | `www-apps/rt` | [GraphViz2-2.670.0.ebuild](/var/db/repos/gentoo/dev-perl/GraphViz2/GraphViz2-2.670.0.ebuild) | `~amd64` |
| `dev-perl/HTML-FormatExternal` | `www-apps/rt` | [HTML-FormatExternal-26.0.0.ebuild](/var/db/repos/gentoo/dev-perl/HTML-FormatExternal/HTML-FormatExternal-26.0.0.ebuild) | `~amd64 ~x86` |
| `dev-perl/HTML-FormatText-WithLinks` | `www-apps/rt` | [HTML-FormatText-WithLinks-0.150.0-r3.ebuild](/var/db/repos/gentoo/dev-perl/HTML-FormatText-WithLinks/HTML-FormatText-WithLinks-0.150.0-r3.ebuild) | `amd64 ~riscv` |
| `dev-perl/HTML-FormatText-WithLinks-AndTables` | `www-apps/rt` | [HTML-FormatText-WithLinks-AndTables-0.70.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/HTML-FormatText-WithLinks-AndTables/HTML-FormatText-WithLinks-AndTables-0.70.0-r2.ebuild) | `amd64 ~riscv` |
| `dev-perl/HTML-Gumbo` | `www-apps/rt` | [HTML-Gumbo-0.190.0.ebuild](/var/db/repos/gentoo/dev-perl/HTML-Gumbo/HTML-Gumbo-0.190.0.ebuild) | `~amd64 ~riscv` |
| `dev-perl/HTML-Mason` | `www-apps/rt` | [HTML-Mason-1.600.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/HTML-Mason/HTML-Mason-1.600.0-r1.ebuild) | `amd64 ppc ~riscv x86` |
| `dev-perl/HTML-Mason-PSGIHandler` | `www-apps/rt` | [HTML-Mason-PSGIHandler-0.530.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/HTML-Mason-PSGIHandler/HTML-Mason-PSGIHandler-0.530.0-r1.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/HTML-Quoted` | `www-apps/rt` | [HTML-Quoted-0.50.0.ebuild](/var/db/repos/gentoo/dev-perl/HTML-Quoted/HTML-Quoted-0.50.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/HTML-RewriteAttributes` | `www-apps/rt` | [HTML-RewriteAttributes-0.60.0.ebuild](/var/db/repos/gentoo/dev-perl/HTML-RewriteAttributes/HTML-RewriteAttributes-0.60.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Hash-Merge` | `dev-perl/Hash-Merge-Extra`, `www-apps/rt` | [Hash-Merge-0.302.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Hash-Merge/Hash-Merge-0.302.0-r1.ebuild) | `amd64 ~hppa ppc x86` |
| `dev-perl/JavaScript-Minifier-XS` | `www-apps/rt` | [JavaScript-Minifier-XS-0.160.0.ebuild](/var/db/repos/gentoo/dev-perl/JavaScript-Minifier-XS/JavaScript-Minifier-XS-0.160.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Locale-Maketext-Fuzzy` | `www-apps/rt` | [Locale-Maketext-Fuzzy-0.110.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Locale-Maketext-Fuzzy/Locale-Maketext-Fuzzy-0.110.0-r2.ebuild) | `amd64 ~hppa ppc ~riscv x86` |
| `dev-perl/MooseX-NonMoose` | `www-apps/rt` | [MooseX-NonMoose-0.270.0.ebuild](/var/db/repos/gentoo/dev-perl/MooseX-NonMoose/MooseX-NonMoose-0.270.0.ebuild) | `~amd64` |
| `dev-perl/PerlIO-eol` | `www-apps/rt` | [PerlIO-eol-0.190.0.ebuild](/var/db/repos/gentoo/dev-perl/PerlIO-eol/PerlIO-eol-0.190.0.ebuild) | `amd64 ~ppc ~riscv ~sparc x86` |
| `dev-perl/Regexp-Common-net-CIDR` | `www-apps/rt` | [Regexp-Common-net-CIDR-0.30.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Regexp-Common-net-CIDR/Regexp-Common-net-CIDR-0.30.0-r1.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Scope-Upper` | `www-apps/rt` | [Scope-Upper-0.340.0.ebuild](/var/db/repos/gentoo/dev-perl/Scope-Upper/Scope-Upper-0.340.0.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Starlet` | `www-apps/rt` | [Starlet-0.310.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Starlet/Starlet-0.310.0-r1.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Text-Password-Pronounceable` | `www-apps/rt` | [Text-Password-Pronounceable-0.300.0-r2.ebuild](/var/db/repos/gentoo/dev-perl/Text-Password-Pronounceable/Text-Password-Pronounceable-0.300.0-r2.ebuild) | `amd64 ~riscv ~x86` |
| `dev-perl/Text-WordDiff` | `www-apps/rt` | [Text-WordDiff-0.90.0.ebuild](/var/db/repos/gentoo/dev-perl/Text-WordDiff/Text-WordDiff-0.90.0.ebuild) | `~amd64 ~x86` |
| `dev-perl/Text-Wrapper` | `www-apps/rt` | [Text-Wrapper-1.50.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Text-Wrapper/Text-Wrapper-1.50.0-r1.ebuild) | `amd64 ~hppa ppc ppc64 ~riscv x86` |
| `dev-perl/Want` | `dev-perl/DBIx-SearchBuilder` | [Want-0.290.0-r1.ebuild](/var/db/repos/gentoo/dev-perl/Want/Want-0.290.0-r1.ebuild) | `amd64 ~hppa ppc ~riscv x86` |
| `www-servers/spawn-fcgi` | `www-apps/rt` | [spawn-fcgi-1.6.6.ebuild](/var/db/repos/gentoo/www-servers/spawn-fcgi/spawn-fcgi-1.6.6.ebuild) | `~alpha amd64 arm ~hppa ppc ppc64 ~sparc x86` |

NOT VERIFIED: every missing dependency’s complete native arm64 test suite, normal resolver closure under all RT USE alternatives, and RT runtime/database behavior. Resolving these repository keyword exceptions requires separate validation and keyword work; they were explicitly documented instead of changing unrelated dependency packages or bypassing normal resolver policy.

### Native RT 6 phase validation with temporary libraries

VERIFIED on 2026-10-04: RT 6.0.3 completed `clean unpack prepare configure compile install` on server01 (amd64) and gentoo (native arm64) with eight dependencies supplied from temporary package images. Both commands returned exit 0; each RT image contained 2,415 files and the patched TSVExport template, with no temporary library paths embedded. Literal dependency-check output on each host: `All dependencies found.` The full commands, deliberate temporary PERL5LIB configuration, stdout and remaining test limits are documented in [the follow-up audit](overlay-upgrade-review-2026-10-04.md#follow-up-rt-security-and-openclaw-image-corrections). All images were under /tmp/codex and were cleaned afterward; no live package merge or installation occurred.

This result verifies native phase/image construction for postgres/apache with graphviz and FastCGI disabled. It does not resolve any of the 51 repository keyword exceptions listed above, validate every runtime dependency, test database/application behavior, or establish Gentoo keywording/stabilization.
