const assert = require('node:assert/strict');
const path = require('node:path');
const { createRequire } = require('node:module');

const resources = path.join(path.dirname(process.execPath), 'resources');
const packagedRequire = createRequire(path.join(resources, 'sqlite-worker.bundle.js'));

(async () => {
  const Database = packagedRequire('better-sqlite3');
  const db = new Database(':memory:');
  assert.equal(db.prepare('SELECT 42 AS value').get().value, 42);
  db.close();
  console.log('Packaged SQLite query: OK');

  const ort = packagedRequire('onnxruntime-node');
  assert.equal(new ort.Tensor('float32', new Float32Array([1]), [1]).data[0], 1);
  console.log('Packaged ONNX native module import and tensor construction: OK');

  const pty = require(path.join(resources, 'node-pty'));
  await new Promise((resolve, reject) => {
    const child = pty.spawn('/bin/sh', ['-c', 'printf nimbalyst-native-pty'], {
      cwd: process.cwd(), env: process.env,
    });
    let output = '';
    const timer = setTimeout(() => { child.kill(); reject(new Error('PTY timeout')); }, 10000);
    child.onData(data => { output += data; });
    child.onExit(({ exitCode }) => {
      clearTimeout(timer);
      try {
        assert.equal(exitCode, 0);
        assert(output.includes('nimbalyst-native-pty'));
        resolve();
      } catch (error) { reject(error); }
    });
  });
  console.log('Packaged node-pty shell execution: OK');
  console.log(`Runtime: Electron ${process.versions.electron}, arch ${process.arch}`);
})().catch(error => { console.error(error); process.exitCode = 1; });
