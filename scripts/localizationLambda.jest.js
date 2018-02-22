const {
  ignoreErrors,
  validCountryCodes,
  validCountryCodesLength,
  dontProcess,
  dontProcessLength,
  isValidCountryCode,
  getPathCountryCode,
  getHeaderCountryCode,
  getCookieCountryCode,
  pathWithoutCountryCode,
  handler,
} = require('./localizationLambda.js');

const codes = ['au', 'ca', 'nz', 'uk'];
const badCodes = ['us', 'EU', 'NZD', 'aud', 'gb', '1'];

// I know this is weird.
const codesInAllCases = [].concat.apply([], codes.map(code => [
  code,
  code.toUpperCase(),
  code[0].toUpperCase() + code[1],
  code[0] + code[1].toUpperCase(),
]));

const blogUris = ['/blog', '/blog/', '/blog/some-blog-url/'];
const assetUris = [
  '/js/some-file-12389a.js/',
  '/css/styles.css',
  '/img/image-name.jpg',
  '/font/font.woff',
  '/assets/video.mp4',
  'music.mp3',
  '.jsx',
  '.htaccess',
  'file.html',
  'sitemap.xml',
];

const generateCloudFrontEvent = (uri = '', cookieCountry, viewerCountry) => {
  let event = {
    Records: [
      {
        cf: {
          request: {
            headers: {},
            uri,
            method: "GET"
          },
          response: {
            headers: {},
            status: 200,
            statusDescription: 'OK',
            body: 'Some stuff!'
          }
        }
      }
    ]
  };

  if (cookieCountry) {
    event.Records[0].cf.request.headers.cookie = [
      { value: `some-cookie=GA12489102380;` },
      { value: `sharesight_country=${cookieCountry}` },
    ]
  }

  if (viewerCountry) {
    event.Records[0].cf.request.headers['cloudfront-viewer-country'] = [{
      key: 'Cloudfront-Viewer-Country',
      value: viewerCountry,
    }];
  }

  return event;
}

describe('localizationLambda', () => {
  describe('ignoreErrors', () => {
    test('ignores a strictly thrown error and returns undefined', () => {
      expect(ignoreErrors(() => {
        throw new Error('This is an error');
      })).toEqual(undefined);
    })

    test('ignores a code error and returns undefined', () => {
      expect(ignoreErrors(() => {
        a += 's' * 2 / 0 + thisIsUndefined;
      })).toEqual(undefined);
    })

    test('returns the response when there are no errors', () => {
      expect(ignoreErrors(() => 'valid')).toEqual('valid');
    })
  });

  describe('validCountryCodes', () => {
    test('array matches', () => {
      expect(validCountryCodes).toEqual(codes);
    })

    test('length matches', () => {
      expect(validCountryCodesLength).toEqual(validCountryCodes.length)
    });
  });

  describe('dontProcess', () => {
    test('length matches', () => {
      expect(dontProcessLength).toEqual(dontProcess.length)
    });

    test('ignores blogs', (done) => {
      expect.assertions(blogUris.length);

      blogUris.forEach(uri => {
        let didMatch = false;
        for (let i=0; i < dontProcessLength; i++) {
          if (uri.match(dontProcess[i])) {
            didMatch = true;
            break;
          }
        }

        expect(didMatch).toEqual(true);
      });

      done();
    });

    test('ignores assets', (done) => {
      expect.assertions(assetUris.length);

      assetUris.forEach(uri => {
        let didMatch = false;
        for (let i=0; i < dontProcessLength; i++) {
          if (uri.match(dontProcess[i])) {
            didMatch = true;
            break;
          }
        }

        expect(didMatch).toEqual(true);
      });

      done();
    });
  });

  describe('isValidCountryCode', () => {
    test('should return true when valid, regardless of case', () => {
      expect.assertions(codesInAllCases.length);

      codesInAllCases.forEach(code => {
        expect(isValidCountryCode(code)).toEqual(true);
      });
    });

    test('should return false when unknown', () => {
      expect(isValidCountryCode('US')).toEqual(false);
      expect(isValidCountryCode('EU')).toEqual(false);
      expect(isValidCountryCode(1)).toEqual(false);
      expect(isValidCountryCode({})).toEqual(false);
      expect(isValidCountryCode(/whatever man/)).toEqual(false);
    });
  });

  describe('getPathCountryCode', () => {
    test('should return the normalized country code when a valid country code is found, regardless of case', () => {
      expect(getPathCountryCode('/nz')).toEqual('nz');
      expect(getPathCountryCode('/nZ/')).toEqual('nz');
      expect(getPathCountryCode('/AU/something')).toEqual('au');
      expect(getPathCountryCode('/ca/some/url/path/')).toEqual('ca');
      expect(getPathCountryCode('/UK/nz/ca/au/')).toEqual('uk');
    });

    test('should return undefined when country code is unknown', () => {
      expect(getPathCountryCode('/US')).toEqual(undefined);
      expect(getPathCountryCode('/EU/')).toEqual(undefined);
      expect(getPathCountryCode('/nz1/something')).toEqual(undefined);
      expect(getPathCountryCode('/no-locale')).toEqual(undefined);
      expect(getPathCountryCode('/nzd/')).toEqual(undefined);
      expect(getPathCountryCode('/nzd')).toEqual(undefined);
      expect(getPathCountryCode('nz')).toEqual(undefined);
      expect(getPathCountryCode('au/')).toEqual(undefined);
    });
  });

  describe('getHeaderCountryCode', () => {
    test('should return the normalized country code when a valid country code is found, regardless of case', () => {
      expect.assertions(codesInAllCases.length);

      codesInAllCases.forEach(code => {
        const request = { headers: {
          'cloudfront-viewer-country': [{
            key: 'Cloudfront-Viewer-Country', // pretty sure that matches, doesn't matter
            value: code,
          }]
        }}

        expect(getHeaderCountryCode(request)).toEqual(code.toLowerCase());
      });
    });

    test('should return undefined when header is missing', () => {
      let request = { headers: { 'cloudfront-viewer-country': [{}] } } // bare mininmum

      expect(getHeaderCountryCode(request)).toEqual(undefined);
    });

    test('should return undefined with an unknown code', () => {
      expect.assertions(badCodes.length);

      badCodes.forEach(code => {
        const request = { headers: { 'cloudfront-viewer-country': [{ value: code, }] } }

        expect(getHeaderCountryCode(request)).toEqual(undefined);
      })
    });
  });

  describe('getCookieCountryCode', () => {
    test('should return the normalized country code when a valid country code is found, regardless of case', () => {
      expect.assertions(codesInAllCases.length);

      codesInAllCases.forEach(code => {
        const request = { headers: {
          cookie: [
            { value: `asdf3fu13=LJKFu38faud` },
            { value: `sharesight_country = false; sharesight=LJKFu38fau;` },
            { value: `sharesight_country=; au=nz` },
            { value: `; sharesight_country=${code} ;` }
          ]
        }}

        expect(getCookieCountryCode(request)).toEqual(code.toLowerCase());
      });
    });

    test('should return the first valid, normalized country found, even in some weird cookie situations', () => {
      const request = { headers: {
        cookie: [
          { value: `sharesight_country; country=au;` },
          { value: `sharesight_country;=ca;` }, // does splits on semi-colons
          { value: `sharesight_country=;;;; au=ca` },
          { value: `sharesight_country=us` }, // first legit response, but not valid
          { value: `;;;ca;; sharesight_country=nz ;;;` }, // first valid response, this is the expectation!
          { value: `sharesight_country=uk` },
          { value: `sharesight_country=ca` },
          { value: `sharesight_country=au` },
        ]
      }}

      expect(getCookieCountryCode(request)).toEqual('nz');
    });

    test('should return undefined when header is missing', () => {
      let request = { headers: { cookie: [{}] } } // bare mininmum

      expect(getCookieCountryCode(request)).toEqual(undefined);
    });

    test('should return undefined with a bad code', () => {
      expect.assertions(badCodes.length);

      badCodes.forEach(code => {
        const request = { headers: { cookie: [{ value: `sharesight_country=${code}` }] } }

        expect(getCookieCountryCode(request)).toEqual(undefined);
      })
    });
  });

  describe('pathWithoutCountryCode', () => {
    test('should strip out the country code', () => {
      expect.assertions(codesInAllCases.length * 3);

      codesInAllCases.forEach(code => {
        expect(pathWithoutCountryCode(`/${code}`)).toEqual('');
        expect(pathWithoutCountryCode(`/${code}/`)).toEqual('/');
        expect(pathWithoutCountryCode(`/${code}/foo`)).toEqual('/foo');
      });
    });

    test('should not strip anything with bad codes', () => {
      expect.assertions(badCodes.length * 3);

      badCodes.forEach(code => {
        expect(pathWithoutCountryCode(`/${code}`)).toEqual(`/${code}`);
        expect(pathWithoutCountryCode(`/${code}/`)).toEqual(`/${code}/`);
        expect(pathWithoutCountryCode(`/${code}/foo`)).toEqual(`/${code}/foo`);
      });
    });
  });

  describe('handler', () => {
    test('should ignore blogs', () => {
      expect.assertions(blogUris.length * 3);

      blogUris.forEach(uri => {
        const mockCallback = jest.fn();
        const event = generateCloudFrontEvent(uri);
        const handled = handler(event, null, mockCallback);

        expect(mockCallback.mock.calls.length).toEqual(1);
        expect(mockCallback.mock.calls[0][0]).toEqual(null);
        expect(mockCallback.mock.calls[0][1]).toEqual(event.Records[0].cf.response);
      });
    });

    test('should ignore assets', () => {
      expect.assertions(assetUris.length * 3);

      assetUris.forEach(uri => {
        const mockCallback = jest.fn();
        const event = generateCloudFrontEvent(uri);
        const handled = handler(event, null, mockCallback);

        expect(mockCallback.mock.calls.length).toEqual(1);
        expect(mockCallback.mock.calls[0][0]).toEqual(null);
        expect(mockCallback.mock.calls[0][1]).toEqual(event.Records[0].cf.response);
      });
    });

    test('should do nothing when the cookie locale matches the request page locale', () => {
      const mockCallback = jest.fn();
      const event = generateCloudFrontEvent('/nz/faq', 'nz', 'ca');
      const handled = handler(event, null, mockCallback);

      expect(mockCallback.mock.calls.length).toEqual(1);
      expect(mockCallback.mock.calls[0][0]).toEqual(null);
      expect(mockCallback.mock.calls[0][1]).toEqual(event.Records[0].cf.response);
    });

    test(`should do nothing when the cloudfront country matches the request page locale and there's no valid cookie locale`, () => {
      const mockCallback = jest.fn();
      const event = generateCloudFrontEvent('/nz/faq', 'us', 'nz');
      const handled = handler(event, null, mockCallback);

      expect(mockCallback.mock.calls.length).toEqual(1);
      expect(mockCallback.mock.calls[0][0]).toEqual(null);
      expect(mockCallback.mock.calls[0][1]).toEqual(event.Records[0].cf.response);
    });

    test(`should respond with a 302 redirect when the cookie locale does not match the page locale`, () => {
      const mockCallback = jest.fn();
      const event = generateCloudFrontEvent('/nz/faq', 'ca', 'nz');
      const eventResponse = Object.assign({}, event.Records[0].cf.response)
      const handled = handler(event, null, mockCallback);

      expect(mockCallback.mock.calls.length).toEqual(1);
      expect(mockCallback.mock.calls[0][0]).toEqual(null);
      expect(mockCallback.mock.calls[0][1]).not.toEqual(eventResponse);
      expect(mockCallback.mock.calls[0][1].status).toEqual(302);
      expect(mockCallback.mock.calls[0][1].statusDescription).toEqual('Found');
      expect(mockCallback.mock.calls[0][1].headers.location[0].value).toEqual('/ca/faq');
    });

    test(`[as a side-effect] should respond with a 302 redirect when the case is incorrect on the locale`, () => {
      const mockCallback = jest.fn();
      const event = generateCloudFrontEvent('/NZ/faq', 'nz', 'nz');
      const eventResponse = Object.assign({}, event.Records[0].cf.response)
      const handled = handler(event, null, mockCallback);

      expect(mockCallback.mock.calls.length).toEqual(1);
      expect(mockCallback.mock.calls[0][0]).toEqual(null);
      expect(mockCallback.mock.calls[0][1]).not.toEqual(eventResponse);
      expect(mockCallback.mock.calls[0][1].status).toEqual(302);
      expect(mockCallback.mock.calls[0][1].statusDescription).toEqual('Found');
      expect(mockCallback.mock.calls[0][1].headers.location[0].value).toEqual('/nz/faq');
    });
  });
});
