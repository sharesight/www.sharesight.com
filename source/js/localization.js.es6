//= require "./config"
//= require "./helpers/cookies"
//= require "./helpers/content"
//= require "./helpers/locale"
//= require "./helpers/page"
//= require "./helpers/url"

const localization = {
  overrideCurrentLocaleId: undefined,

  onLoad() {
    this.ensureCookie();
    this.initializeRegionSelector();
    this.modifyContent();
    this.renderLocaleNotification();
  },

  isGlobalOnlyPage() {
    // NOTE: Could look in `locales.json` (via config.locales) to see if the current path is global.
    if (window.location.pathname.indexOf('/team') === 0) return true;
    if (window.location.pathname.indexOf('/blog') === 0) return true;
    if (window.location.pathname.indexOf('/survey-thanks') === 0) return true;
    if (document.getElementById('_404')) return true;
    return false;
  },

  modifyContent() {
    this.updateUrls();
    contentManager.updateContent();
  },

  renderLocaleNotification() {
    const viewedCountry = urlHelper.getLocalisationFromPath();
    const cookieCountry = localeHelper.getCookieLocale();

    if (!this.isGlobalOnlyPage() && viewedCountry !== cookieCountry) {
      const countryBanner = document.getElementById('countryBanner');
      const viewedCountryLabel = document.getElementById('viewedCountry');
      const viewedCountryLink = document.getElementById('viewedCountryLink');
      const cookieCountryLink = document.getElementById('cookieCountryLink');

      const viewedCountryLocale = localeHelper.getLocale(viewedCountry);
      const cookieCountryLocale = localeHelper.getLocale(cookieCountry);

      // change current country label, just incase it differs (should match the initial render)
      viewedCountryLabel.textContent = viewedCountryLocale.adjective;
      cookieCountryLink.setAttribute(
        'title',
        `stay on the ${viewedCountryLocale.adjective} site`
      );

      // change the cookie country link, title, and text
      cookieCountryLink.textContent = `return to the ${cookieCountryLocale.adjective} site`;
      cookieCountryLink.setAttribute(
        'title',
        `return to the ${cookieCountryLocale.adjective} site`
      );
      cookieCountryLink.href = urlHelper.localizePath(
        window.location.pathname,
        cookieCountry
      );

      // show banner
      countryBanner.style.display = 'flex';

      viewedCountryLink.addEventListener('click', event => {
        // overwrite the cookie
        cookieManager.setCookie(viewedCountry);

        // close the banner
        countryBanner.style.display = 'none';

        event && event.preventDefault();
        return false;
      });
    }
  },

  setLocale(locale_id, force = false) {
    if (localeHelper.isValidLocaleId(locale_id)) {
      locale_id = locale_id.toLowerCase();

      // We override if it's a non-global cookie and the user doesn't have a cookie
      // …or `force=true`
      const shouldOverride = locale_id !== config.default_locale_id && cookieManager.getCookie().length == 0;
      if (force || shouldOverride) {
        this.overrideCurrentLocaleId = locale_id;
        cookieManager.setCookie(locale_id);
      }
    }

    this.modifyContent();
  },

  redirectToLocale(locale_id) {
    // if we're not on a page that begins with the current locale, which should be localized, refresh the page and Cloudfront's localization should kick in
    if (
      !this.isGlobalOnlyPage() &&
      window.location.pathname.indexOf(`/${locale_id}`) !== 0
    ) {
      window.location.href = urlHelper.localizePath(
        window.location.pathname,
        locale_id
      );
    }
  },

  getCurrentLocaleId() {
    if (this.overrideCurrentLocaleId) {
      return this.overrideCurrentLocaleId;
    }

    return urlHelper.getLocalisationFromPath();
  },

  updateUrls() {
    const localeId = this.isGlobalOnlyPage()
      ? localeHelper.getCookieLocale()
      : urlHelper.getLocalisationFromPath();
    [].concat
      .apply(
        [], // flatten arrays of arrays
        [
          config.base_url, // absolute urls (www.sharesight.com)
          config.help_url, // help site (help.sharesight.com)
          `${config.base_path}/`.replace(/\/+/g, '/'), // relative urls (/faq); replace duplicate slashes
        ].map(path =>
          Array.from(document.querySelectorAll(`a[href^="${path}"]`))
        )
      )
      .forEach(element => {
        if (element.hasAttribute('data-no-localize')) return; // don't localize urls with no-localize
        if (!urlHelper.shouldLocalizeUrl(element.href, localeId)) return; // don't localize

        element.pathname = urlHelper.localizePath(element.pathname, localeId);
      });
  },

  getRegionSelectorNode() {
    if (this.regionSelector) return this.regionSelector;
    this.regionSelector = document.getElementById('region_selector');
    return this.regionSelector;
  },

  /**
   * Ensure a user's non-global locale cookie is set.
   * If the user has a cookie or they're on a global path, keep it unset.
   */
  ensureCookie() {
    if (cookieManager.getCookie().length > 0) return;

    const pathLocaleId = urlHelper.getLocalisationFromPath();

    // Do not set the locale if it's the global locale.
    if (pathLocaleId && pathLocaleId !== config.default_locale_id) {
      this.setLocale(pathLocaleId);
    }
  },

  initializeRegionSelector() {
    const self = this;
    const selector = this.getRegionSelectorNode();
    if (!selector || !selector.options || !selector.options.length) return;

    // Modify the Region Selector to have the current cookie value…
    this.setRegionSelectorValue();

    // Then…now that we've set it…set the cookie?  NOTE: This seems a bit cyclical; confused by old code here.
    this.initializeLocaleCookieFromRegionSelector();

    // When the Region Selector changes, forcibly set the locale cookie and go to that locale.
    selector.onchange = function () {
      self.setLocale(this.value, true);
      self.redirectToLocale(this.value);
    };
  },

  setRegionSelectorValue() {
    const selector = this.getRegionSelectorNode();
    if (!selector) return;
    if (selector.value === localeHelper.getCookieLocale()) return; // nothing to change then

    // set the region selector to match the current locale on unlocalized pages
    Array.from(selector.options).forEach(option => {
      option.removeAttribute('selected');

      if (option.value.toLowerCase() === localeHelper.getCookieLocale()) {
        option.setAttribute('selected', true);
      }
    });
  },

  initializeLocaleCookieFromRegionSelector() {
    const selector = this.getRegionSelectorNode();

    // don't set a global cookie when the page loads
    if (!selector.value || selector.value === config.default_locale_id) return;

    this.setLocale(selector.value);
  },
};

(function () {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      localization.onLoad();
    });
  } else {
    localization.onLoad();
  }
})();
