from unittest import mock
from types import SimpleNamespace

import pytest
import aqt
from aqt import mediasrv, webview, editor
from aqt.qt import QUrl

@pytest.mark.parametrize('url,allowed', [
    ('http://127.0.0.1:12345/_anki/x', True),
    ('http://127.0.0.1:12346/_anki/x', False),
    ('https://127.0.0.1:12345/_anki/x', False),
    ('http://example.invalid:12345/_anki/x', False),
])
def test_bearer_only_on_exact_server_origin(monkeypatch, url, allowed):
    monkeypatch.setattr(aqt, 'mw', SimpleNamespace(serverURL=lambda: 'http://127.0.0.1:12345/'), raising=False)
    monkeypatch.setattr(webview, 'hmr_mode', False)
    info = mock.Mock()
    info.requestUrl.return_value = QUrl(url)
    webview.AuthInterceptor.interceptRequest(SimpleNamespace(_api_enabled=True), info)
    assert info.setHttpHeader.called is allowed

@pytest.mark.parametrize('path', ['/tmp/payload.exe', '/tmp/payload.desktop', '/tmp/payload.sh', '/tmp/payload.html', '/tmp/no_extension'])
def test_open_image_rejects_nonimages(path):
    menu = mock.Mock()
    editor.EditorWebView._add_image_menu_with_path(mock.Mock(), menu, path)
    menu.addAction.assert_not_called()

@pytest.mark.parametrize('path', ['/tmp/safe.png', '/tmp/safe.svg', '/tmp/safe.webp'])
def test_open_image_keeps_images(monkeypatch, path):
    menu = mock.Mock()
    monkeypatch.setattr(editor, 'qconnect', mock.Mock())
    monkeypatch.setattr(editor, 'tr', mock.Mock())
    editor.EditorWebView._add_image_menu_with_path(mock.Mock(), menu, path)
    assert menu.addAction.call_count == 2

@pytest.mark.parametrize('path', ['image-occlusion', 'image-occlusion/42'])
def test_actual_occlusion_route_uses_untrusted_policy(monkeypatch, path):
    monkeypatch.setattr(aqt, 'mw', SimpleNamespace(mediaServer=SimpleNamespace(getPort=lambda: 12345)), raising=False)
    data = b'<meta http-equiv="content-security-policy" content="script-src \'self\' \'sha256-abc=\'">'
    monkeypatch.setattr(mediasrv, '_builtin_data', lambda path: data)
    with mediasrv.app.test_request_context():
        request = mediasrv._extract_internal_request(path)
        response = mediasrv._handle_builtin_file_request(request)
    policy = response.headers['Content-Security-Policy']
    assert "'sha256-abc='" in policy
    assert "frame-ancestors 'none'" in policy
    assert "form-action 'none'" in policy
    assert "'unsafe-inline'" not in policy

@pytest.mark.parametrize('origin', ['http://attacker.invalid', 'http://127.0.0.1.attacker.invalid:12345'])
def test_http_server_rejects_remote_origins(monkeypatch, origin):
    monkeypatch.delenv('ANKI_API_HOST', raising=False)
    response = mediasrv.app.test_client().post('/_anki/updateDeckConfigs', headers={'Host': '127.0.0.1:12345', 'Origin': origin})
    assert response.status_code == 403

@pytest.mark.parametrize('payload', ["<script>alert('xss')</script>", "</li><script>fetch('/poc.jpg')</script><li>"])
def test_empty_cards_names_strip_active_html(tmp_path, payload):
    from anki.collection import Collection
    col = Collection(str(tmp_path / 'test.anki2'))
    try:
        note = col.newNote()
        note['Front'] = 'front'
        note['Back'] = ''
        col.addNote(note)
        model = col.models.current()
        model['name'] = payload + 'Safe Note'
        model['tmpls'][0]['name'] = payload + 'Safe Card'
        model['tmpls'][0]['qfmt'] = '{{Back}}'
        col.models.save(model, templates=True)
        report = col._backend.get_empty_cards().report
        assert 'Safe Note' in report
        assert 'Safe Card' in report
        assert '<script>' not in report
        assert 'fetch(' not in report
    finally:
        col.close(downgrade=False)

def test_installed_occlusion_page_has_real_bootstrap_hash(monkeypatch):
    monkeypatch.setattr(aqt, 'mw', SimpleNamespace(mediaServer=SimpleNamespace(getPort=lambda: 12345)), raising=False)
    with mediasrv.app.test_request_context():
        req = mediasrv._extract_internal_request('image-occlusion/42')
        response = mediasrv._handle_builtin_file_request(req)
    assert response.status_code == 200
    digest = mediasrv._sveltekit_render_script_hash(response.get_data())
    assert digest is not None
    assert digest in response.headers['Content-Security-Policy']
