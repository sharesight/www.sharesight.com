# Localization behaviour for the marketing site

**:warning: This document may not be maintained as this repo is no longer being developed; it should move elsewhere in the future.**

**Definitions:**
 - An _override cookie_ means `sharesight_country`, wherein a user would override their country to AU even if they are in NZ.
 - _Locale_ would mean AU, NZ, CA, UK, US and may be mixed with the terminology of country.

## All Scenarios

 * Trailing slashes are added if missing.
    * `/blog` => `/blog/`
 * All parameters are maintained in when redirecting (localization or trailing slashes)
    * `/blog?utm_source=google` => `/blog/?utm_source=google`
    * `/pricing/?utm_source=google` => `/nz/pricing/?utm_source=google`
 * Requesting `/blog`, `/team`, or a 404ing page
    * We never localize these pages and a cookie is never set.
 * Requesting a localized variant, eg. `/nz/pricing`, `/us/pricing`, etc will never set a cookie.
    * A cookie now only set when the user overrides their setting, eg. says they are specifically from New Zealand.
    * Unless a user has an override cookie of `sharesight_country`, we treat every request as if we need to determine localization from scratch.
 * When a user overrides their locale, they are given a new `sharesight_country` cookie and are redirected or linked to the localized variant of that page.
    * Further page routes will follow the _override cookie_ scenario.
    * NOTE: There's a few issues with the [Middleman](https://github.com/sharesight/www.sharesight.com) codebase where it does not follow this.

## Global User

 * Requesting `/nz/pricing` (any locale)
    * We stay there.
    * With an override cookie: We stay there.
 * Requesting `/pricing` with no override 
    * We stay there.
    * With an override cookie: We redirect to the override, eg. `/au/pricing`.

## AU, CA, NZ, UK Users

 * Requesting current locale: NZ User + `/nz/pricing`
    * We stay there.
 * Requesting another locale: NZ User + `/au/pricing`
    * We stay there.
 * Requesting `/pricing`
    * We determine the user's country via AWS Cloudfront's Country Header and redirect them.
    * Eg. `/pricing` => `/nz/pricing/`
