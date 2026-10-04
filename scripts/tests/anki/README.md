# Anki security backport checks

These are maintainer checks for the temporary arm64 source package. They do not
install Anki or use an existing user profile. Run on the native arm64 host
`gentoo`, after the non-merging ebuild phases have produced an image.

Set `ANKI_TEST_SOURCE` to the prepared source directory and `PYTHONPATH` to the
image's Python site-packages. Set `TMPDIR` and pytest's `cache_dir` inside the
package's `/tmp/codex/app-misc/anki-25.09.2` workspace. Use the Python interpreter
that built the image (Python 3.14 for the recorded run).

```sh
python3.14 -m pytest -q -o addopts= -o cache_dir="$TMPDIR/pytest-cache" \
    "$ANKI_TEST_SOURCE/qt/tests/test_mediasrv.py" test_security_backport.py
python3.14 qwebengine_csp_smoke.py
```

The image-based checks require `ANKI_TEST_MODE=1` and `QT_QPA_PLATFORM=offscreen`.
The CSP smoke script uses prepared source modules and generated output and runs
an offscreen QtWebEngine against local fixture servers. Its upstream test setup
explicitly disables Chromium's process sandbox; it loads only generated test
pages and does not use a normal Anki profile or browse external sites.

`qwebengine_csp_smoke.py` is the upstream 26.09.3 regression script, with its
source root provided by `ANKI_TEST_SOURCE` instead of inferred from its location.
Source: https://github.com/ankitects/anki/blob/26.09.3/qt/tests/qwebengine_csp_smoke.py

`test_security_backport.py` adds boundary checks for the legacy image menu,
exact-origin bearer-token handling, remote-origin rejection, real image-occlusion
routing and its installed bootstrap hash, and HTML injection in empty-card
reports using the compiled backend and a new collection under pytest's tmpdir.

The full upstream Python/Rust/JS suite is separate; these focused checks do not
claim full test-suite coverage. Recorded outcomes are in
`docs/anki-security-backport-validation.md`.
