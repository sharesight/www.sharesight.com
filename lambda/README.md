# Cloudfront + Lambda for localization and security headers

## ⚠️ WARNING ⚠️
**This is currently only used on https://help.sharesight.com.  The new source is at https://github.com/sharesight/static-cloudfront.**

---
#### AWS May change!

- AWS may not support the latest or LTS Node version.
- Their UI has changed and may continue to change, these instructions may become out of date quickly.
- In the past, some of the Examples and screenshots in their own documentation are incorrect and do not match reality.

## Why

- We want to serve users their localized content.
- We want to include security headers to static website response.

## Tests

- Run `yarn jest`.

## Deployment

- Merge your changes to the `develop` branch before running these steps. There could be multiple testing versions of this lambda file around and you should always work with the merged copy, not your own copy, when modifying staging.
- Bump Line ~13 in `localizationLambda.js`, eg. `const version = '10';`. This is used for debugging.
- Test code changes first via `yarn jest` and improve `./localizationLambda.jest.js` whenever you make changes!
- Visit the [Lambda](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/localizeCloudfrontResponse/versions/$LATEST)
- Paste the contents of `./localizationLambda.js` into the code section of `$LATEST`.
- Under `Actions`, select `Publish a New Version`. Cloudfront can only run versioned Lambdas, not aliased or $LATEST.
- On the newly published version, drag the Cloudfront trigger onto the Lambda actions/triggers section. This means "when Cloudfront does something, do this Lambda".
- Example Trigger: distributionId: E1LG497M3L1WGH, cacheBehavior: \*, event: Origin Response
- Alternatively, go into the Cloudfront Endpoint > Behavior Tab > Select the Behavior (eg. \*), and at the bottom of the page, change or set the version of the Lambda for _Origin Response_ to match the version you just published.
- Invalidate everything, if necessary via Invalidations Tab: `/*`...
- NOTE: You can assign different versions to different Cloudfront Endpoints! So if you're testing a change, you assign version [100] to `staging-www.sharesight.com` and keep version [95] to `www.sharesight.com`.

## Cloudfront Behavior

- whitelist headers: `CloudFront-Viewer-Country`
- whitelist cookies: `sharesight_country`

## Caching

- Cloudfront caches, that's the point. Be sure to invalidate if you make changes that require it.
- We cache based on `sharesight_country` cookie + `cloudfront-viewer-country` header.
- This means that when someone visits `/nz/faq`, Cloudfront looks to see if a user with countryHeader=NZ and countryCookie=CA has been cached.
  - If so, it would respond with the cached response, which is the 302 previously created by this Lambda – `302 Found => /ca/faq/`.
  - If not, it would run through the Lambda, return a response (`302 Found => /ca/faq/`) and cache that response for future visits.
  - NOTE: This means we have a lot of caches! Our possible cache set is `countries * (supported_countries + 1)`. As we add more locales, this gets bigger.
  - Luckily, most of our users are from the same places. It's not really an issue. Even if it was an issue, Cloudfront can handle this.

## Known Issues

- If a page does not exist in a locale (eg. there is no /ca/page and you visit a valid /nz/page), the user will get a 404 (yet the link itself would not have 404'd).
