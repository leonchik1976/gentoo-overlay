/* Fetch the exact upstream Yarn locators from Portage distfiles, without HTTP. */
module.exports = {
  name: 'portage-offline',
  factory: require => {
    const fs = require('fs');
    const path = require('path');
    const crypto = require('crypto');
    return {hooks: {
      wrapNetworkRequest: async (_executor, {target, method}) => async () => {
        const url = new URL(target);
        const match = decodeURIComponent(url.pathname).match(/^\/(.+)\/-\/([^/]+)\.tgz$/);
        if (method !== 'GET' || !['registry.npmjs.org', 'registry.yarnpkg.com'].includes(url.hostname) || !match)
          throw new Error('Unexpected network request during offline build: ' + target);
        const name = match[1];
        const basename = name.split('/').pop();
        if (!match[2].startsWith(basename + '-')) throw new Error('Invalid npm tarball URL: ' + target);
        const version = match[2].slice(basename.length + 1);
        const uri = 'https://registry.npmjs.org/' + name + '/-/' + basename + '-' + version + '.tgz';
        const filename = 'anki-npm-' + crypto.createHash('sha256').update(uri).digest('hex').slice(0, 20) + '.tgz';
        return {body: fs.readFileSync(path.join(process.env.ANKI_NPM_DISTDIR, filename)),
          headers: {}, statusCode: 200, statusMessage: 'Portage distfile'};
      },
    }};
  },
};
