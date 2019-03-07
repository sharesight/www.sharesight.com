//= require "./config"
//= require "./helpers/cookies"
//= require "./helpers/content"
//= require "./helpers/locale"
//= require "./helpers/page"
//= require "./helpers/url"

const localization = {
  requestedLocaleId: "global",
  setLocaleId: false,

  onLoad () {
    this.initializeRequestedLocaleId()
    this.ensureCookie()
    this.initializeRegionSelector()
    this.modifyContent()
    this.renderLocaleNotification()
  },

  isGlobalOnlyPage () {
    if (window.location.pathname.indexOf('/blog') === 0) return true
    if (window.location.pathname.indexOf('/survey-thanks') === 0) return true
    if (document.getElementById('_404')) return true
    return false
  },

  modifyContent () {
    this.updateUrls()
    contentManager.updateContent()
  },

  renderLocaleNotification () {
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
      cookieCountryLink.setAttribute('title', `stay on the ${viewedCountryLocale.adjective} site`);

      // change the cookie country link, title, and text
      cookieCountryLink.textContent = `return to the ${cookieCountryLocale.adjective} site`;
      cookieCountryLink.setAttribute('title', `return to the ${cookieCountryLocale.adjective} site`);
      cookieCountryLink.href = urlHelper.localizePath(window.location.pathname, cookieCountry);

      // show banner
      countryBanner.style.display = 'flex';

      viewedCountryLink.addEventListener('click', (event) => {
        // overwrite the cookie
        cookieManager.setCookie(viewedCountry);

        // close the banner
        countryBanner.style.display = 'none';

        event && event.preventDefault();
        return false;
      });
    }
  },

  setLocale (locale_id, force = false) {
    if (!locale_id || typeof locale_id !== 'string' || !localeHelper.isValidLocaleId(locale_id)) {
      locale_id = config.default_locale_id
    }

    locale_id = locale_id.toLowerCase()

    this.setLocaleId = locale_id
    if (force || cookieManager.getCookie().length == 0) {
      cookieManager.setCookie(locale_id)
    }
    this.modifyContent()
  },

  redirectToLocale (locale_id) {
    // if we're not on a page that begins with the current locale, which should be localized, refresh the page and Cloudfront's localization should kick in
    if (!this.isGlobalOnlyPage() && window.location.pathname.indexOf(`/${locale_id}`) !== 0) {
      window.location.href = urlHelper.localizePath(window.location.pathname, locale_id);
    }
  },

  getCurrentLocaleId () {
    if (this.setLocaleId) {
      return this.setLocaleId;
    }
    // return localeHelper.getCookieLocale();
    return urlHelper.getLocalisationFromPath();
  },

  updateUrls () {
    const localeId = this.isGlobalOnlyPage() ? localeHelper.getCookieLocale() : urlHelper.getLocalisationFromPath();
    ;[].concat.apply([], // flatten arrays of arrays
      [
        config.base_url, // absolute urls (www.sharesight.com)
        config.help_url, // help site (help.sharesight.com)
        `${config.base_path}/`.replace(/\/+/g, '/'), // relative urls (/faq); replace duplicate slashes
      ].map(path => Array.from(document.querySelectorAll(`a[href^="${path}"]`)))
    ).forEach((element) => {
      if (element.hasAttribute('data-no-localize')) return; // don't localize urls with no-localize
      element.pathname = urlHelper.localizePath(element.pathname, localeId)
    })
  },

  getRegionSelectorNode () {
    if (this.regionSelector) return this.regionSelector
    this.regionSelector = document.getElementById('region_selector')
    return this.regionSelector
  },

  initializeRequestedLocaleId () {
    this.requestedLocaleId = urlHelper.getLocalisationFromPath()
  },

  ensureCookie () {
    if (cookieManager.getCookie().length > 0) return
    this.setLocale(this.requestedLocaleId)
  },

  initializeRegionSelector () {
    const self = this
    const selector = this.getRegionSelectorNode();
    if (!selector || !selector.options || !selector.options.length) return

    this.setRegionSelectorValue()
    this.setCookieFromRegionSelector();

    // when it changes, set locale
    selector.onchange = function () {
      self.setLocale(this.value, true);
      self.redirectToLocale(this.value);
    }
  },

  setRegionSelectorValue () {
    const selector = this.getRegionSelectorNode();
    if (!selector) return;
    if (selector.value === localeHelper.getCookieLocale()) return // nothing to change then

    // set the region selector to match the current locale on unlocalized pages
    Array.from(selector.options).forEach(option => {
      option.removeAttribute('selected')

      if (option.value.toLowerCase() === localeHelper.getCookieLocale()) {
        option.setAttribute('selected', true)
      }
    })
  },

  setCookieFromRegionSelector () {
    const selector = this.getRegionSelectorNode()
    if (selector.value === config.default_locale_id) return // don't set a global cookie when the page loads
    this.setLocale(selector.value)
  },
}

;(() => {
  document.addEventListener('DOMContentLoaded', () => {
    localization.onLoad()
  })
})()
