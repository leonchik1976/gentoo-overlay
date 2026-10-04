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
