'use strict';

/*
 * NOTE: This is an ORIGIN RESPONSE Lambda running on Node v6.10.
 * If the Node version changes, this code may need major refactor.
 * It takes a request + response and returns a response.
 * When we should redirect, the response is a 302 in the case of "We found the proper locale for you", in all other cases it simply returns the response you were meant to have.
 *
 * This must be deployed *MANUALLY*.  See `../lambda/README.md`.
 * If you are viewing this file inside of AWS, this code comes from https://github.com/sharesight/www.sharesight.com/.
 */

const validCountryCodes = { au: 'au', ca: 'ca', nz: 'nz', gb: 'uk', uk: 'uk' };
const validCountryCodesLength = Object.keys(validCountryCodes).length; // cache this

// dontProcess turns off all processing (ultimately, localization)
const dontProcess = [
  /^\/blog\/?/, // don't localize the blog
  /\.[A-z0-9]{2,4}\/?$/, // don't process files; eg.: xml, html, txt, mp4, etc
  /\.htaccess\/?$/,
];
const dontProcessLength = dontProcess.length;

function ignoreErrors (fn) {
  try {
    return fn();
  } catch (e) {
    // We actually don't care, sadly, and this will probably never get logged.
    // If this fails, Cloudfront has changed...  An error here would result in a 503 on every response, so we ignore it.
    console.log('Error@getHeaderCountryCode', e);
  }
}

function getCountryCode (code) {
  if (!code || typeof code !== 'string') return undefined;
  code = code.toLowerCase();
  return validCountryCodes[code];
}

function getPathCountryCode (uri) {
  if (!uri || typeof uri !== 'string' || uri.length < 3) return;
  uri = uri.toLowerCase();

  for (let i = 0; i < validCountryCodesLength; i++) {
    const code = Object.keys(validCountryCodes)[i];
    if (
      code &&
      uri.indexOf(`/${code}`) === 0 && // eg. startsWith
      (uri.length === 3 || // if only 3 characters, then it matches 100%
        (uri.length > 3 && uri.indexOf('/', 1) === 3) // if 4+ length, it must have a trailing slash, eg. /nz/, not /nzd-something
      )
    ) {
      return code; // return found country
    }
  }
}

function getHeaderCountryCode (request) {
  return ignoreErrors(() => {
    let code = request.headers['cloudfront-viewer-country'][0].value;
    code = getCountryCode(code);
    return code;
  })
}

function getCookieCountryCode (request) {
  return ignoreErrors(() => {
    const cookieName = 'sharesight_country';

    if (Array.isArray(request.headers.cookie)) {
      // NOTE: A cookie may have multiple values on it, so we join and split again
      const cookies = request.headers.cookie.map(cookie => cookie.value).join(';');
      const regex = new RegExp(`^\\s*${cookieName}\\s*=\\s*(.*?)\\s*$`);

      // Look at all cookies, regex them, and pass matching strings on, then filter out undefineds, and grab the first result
      const codes = cookies.split(';')
        .map(cookie => {
          const match = regex.exec(cookie.trim());
          if (!Array.isArray(match)) return undefined;
          return getCountryCode(match[1]);
        })
        .filter(a => a);

      return codes[0]; // could have multiple cookies, I suppose
    }
  });
}

function pathWithoutCountryCode (path) {
   // If the path starts with a country code, strip it by only taking everything from [3] onward.
   // eg: /nz/foo becomes /foo and /nz is discarded
  if (getPathCountryCode(path)) return path.slice(3);
  return path;
}

const handler = function (event, context, callback) {
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;

    // if we don't want to localize the url, eg. Blogs
    for (let i=0; i < dontProcessLength; i++) {
      if (request.uri.match(dontProcess[i])) {
        console.log(`Matched a dontProcess (${dontProcess[i]}), returning.`);
        callback(null, response);
        return;
      }
    }

    if (response.status < 200 || response.status >= 300) {
      console.log(`Response status from origin was outside of 2xx; it's unlikely that localization would be valid.`);
      callback(null, response);
      return;
    }

    const cookieCountryCode = getCookieCountryCode(request);
    const headerCountryCode = getHeaderCountryCode(request);
    let newUri = request.uri;

    newUri = pathWithoutCountryCode(newUri);

    if (cookieCountryCode) {
      newUri = `/${cookieCountryCode}/${newUri}`;
      console.log(`Localized using a cookie; new uri: ${newUri}`);
    } else if (headerCountryCode) {
      newUri = `/${headerCountryCode}/${newUri}`;
      console.log(`Localized using the cloudfront header; new uri: ${newUri}`);
    }

    newUri = newUri.replace(/\/+/g, '/'); // replace duplicate forward slashes in path

    if (newUri === request.uri) {
      console.log('URIs match, stopping.');
      callback(null, response);
      return;
    }

    if (request.querystring) newUri += `?${request.querystring}`;

    response.status = 302;
    response.statusDescription = 'Found';
    response.body = ''; // drop the body on redirects
    response.headers['location'] = [{ key: 'Location', value: newUri }];

    // return a 302 to redirect them to the new page
    callback(null, response);
};

module.exports = {
  // exporting all so we can test it
  ignoreErrors: ignoreErrors,
  validCountryCodes: validCountryCodes,
  validCountryCodesLength: validCountryCodesLength,
  dontProcess: dontProcess,
  dontProcessLength: dontProcessLength,
  getCountryCode: getCountryCode,
  getPathCountryCode: getPathCountryCode,
  getHeaderCountryCode: getHeaderCountryCode,
  getCookieCountryCode: getCookieCountryCode,
  pathWithoutCountryCode: pathWithoutCountryCode,
  handler: handler,
};
