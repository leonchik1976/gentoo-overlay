// Copyright 2026 Gentoo Authors
// Distributed under the terms of the GNU General Public License v2

// SWC's temporary mode verifies the carrier payload and cache ancestry, then
// unlinks the materialized image after loading. Portage's build directories
// can have group-writable ancestors, so use the trusted system temporary root
// only for this synchronous load. Jest and its tests retain Portage's TMPDIR.
const { createRequire } = require('node:module');
const { resolve } = require('node:path');

const load = createRequire(resolve('../../packages/jest-swc-preset/package.json'));
const saved = new Map(['TMPDIR', 'SWC_NATIVE_BINDING_CACHE'].map(
  name => [name, process.env[name]],
));
try {
  process.env.TMPDIR = '/tmp';
  process.env.SWC_NATIVE_BINDING_CACHE = '0';
  load('@swc/jest');
} finally {
  for (const [name, value] of saved) {
    if (value === undefined) delete process.env[name];
    else process.env[name] = value;
  }
}
