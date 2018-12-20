# Behaviour for the marketing site

## Locales

Assuming the request is fired from **New Zealand**.

### When no cookie is set

 * requesting `/blog`
    * no locale determining and no cookie setting
    * render `/blog` page
 * requesting `/`
    * determines the **locale** `nz`
    * set the **cookie** to `nz`
    * redirect to `/nz`
 * requesting `/deep-link`
    * determines the **locale** `nz`
    * set the **cookie** to `nz`
    * redirect to `/nz/deep-link`
 * requesting `/xy`
    * assume the **locale** `xy`
    * set the **cookie** to `xy`
    * render `xy` page
 * requesting `/xy/deep-link`
    * assume the **locale** `xy`
    * set the **cookie** to `xy`
    * render `xy/deep-link` page

### When the cookie is set to `xy`

 * requesting `/blog`
    * no locale determining and no cookie setting
    * render `/blog` page
 * requesting `/`
    * no locale determining and no cookie setting
    * redirect to `/xy`
 * requesting `/deep-link`
    * no locale determining and no cookie setting
    * redirect to `/xy/deep-link`
 * requesting `/uk`
    * no locale determining and no cookie setting
    * render `uk` page
 * requesting `/uk/deep-link`
    * no locale determining and no cookie setting
    * render `uk` page
 * requesting to **switch the region to `xy`**
    * set the **cookie** to `xy`
    * redirect to `/xy/deep-link`
