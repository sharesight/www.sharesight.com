//= require "./config"
//= require "./helpers/cookies"
//= require "./helpers/content"
//= require "./helpers/locale"
//= require "./helpers/page"
//= require "./helpers/url"

const localization = {
  setLocaleId: false,

  onLoad () {
    this.initializeRegionSelector()
    this.modifyContent()
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

  setLocale (locale_id) {
    console.log("/setLocale(" + locale_id + ")");
    if (!locale_id || typeof locale_id !== 'string' || !localeHelper.isValidLocaleId(locale_id)) {
      locale_id = config.default_locale_id
    }

    locale_id = locale_id.toLowerCase()

    this.setLocaleId = locale_id
    if (!cookieManager.getCookie()) cookieManager.setCookie(locale_id)
    this.modifyContent()
  },

  redirectToLocale (locale_id) {
    // if we're not on a page that begins with the current locale, which should be localized, refresh the page and Cloudfront's localization should kick in
    console.log("/locale_id = " + `/${locale_id}`);
    if (!this.isGlobalOnlyPage() && window.location.pathname.indexOf(`/${locale_id}`) !== 0) {
      console.log("redirecting...");
      window.location.href = urlHelper.localizePath(window.location.pathname, locale_id);
    } else {
      console.log("isGlobalOnlyPage = " + this.isGlobalOnlyPage());
      console.log("window.location.pathname = " + window.location.pathname);
    }
  },

  getCurrentLocaleId () {
    if (this.setLocaleId) return this.setLocaleId;
    return localeHelper.getCookieLocale();
  },

  updateUrls () {
    ;[].concat.apply([], // flatten arrays of arrays
      [
        config.base_url, // absolute urls (www.sharesight.com)
        config.help_url, // help site (help.sharesight.com)
        `${config.base_path}/`.replace(/\/+/g, '/'), // relative urls (/faq); replace duplicate slashes
      ].map(path => Array.from(document.querySelectorAll(`a[href^="${path}"]`)))
    ).forEach((element) => {
      element.pathname = urlHelper.localizePath(element.pathname)
    })
  },

  getRegionSelectorNode () {
    if (this.regionSelector) return this.regionSelector
    this.regionSelector = document.getElementById('region_selector')
    return this.regionSelector
  },

  initializeRegionSelector () {
    const self = this
    const selector = this.getRegionSelectorNode();
    if (!selector || !selector.options || !selector.options.length) return

    this.setRegionSelectorValue()
    this.setCookieFromRegionSelector();

    // when it changes, set locale
    selector.onchange = function () {
      console.log("setLocale onchange");
      self.setLocale(this.value);
      self.redirectToLocale(this.value);
    }
  },

  setRegionSelectorValue () {
    // console.log("setRegionSelectorValue 0");
    const selector = this.getRegionSelectorNode();
    if (!selector) return;
    // console.log("setRegionSelectorValue 1");
    // const newLocaleId = this.getCurrentLocaleId();
    // console.log("setRegionSelectorValue 2 " + newLocaleId);
    // if (!this.isGlobalOnlyPage()) return // only set the region selector on global pages (eg. blog, which has no locale attached to it)
    // console.log("setRegionSelectorValue 3");
    // if (this.getCurrentLocaleId() === config.default_locale_id) return // don't set a global cookie unless the user changes it themselves
    // console.log("setRegionSelectorValue 4 " + this.getCurrentLocaleId());
    if (selector.value === this.getCurrentLocaleId()) return // nothing to change then
    // console.log("setRegionSelectorValue 5 " + selector.value);

    // set the region selector to match the current locale on unlocalized pages
    Array.from(selector.options).forEach(option => {
      option.removeAttribute('selected')

      if (option.value.toLowerCase() === this.getCurrentLocaleId()) {
        option.setAttribute('selected', true)
      }
    })
  },

  setCookieFromRegionSelector () {
    const selector = this.getRegionSelectorNode()
    if (selector.value === config.default_locale_id) return // don't set a global cookie when the page loads
    console.log("setLocale from region selector");
    this.setLocale(selector.value)
  },
}

;(() => {
  document.addEventListener('DOMContentLoaded', () => {
    localization.onLoad()
  })
})()
