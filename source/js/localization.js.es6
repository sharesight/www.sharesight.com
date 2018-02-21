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

  shouldModifyContent () {
    if (window.location.pathname.match(/^\/?blog/)) return true
    if (document.getElementById('_404')) return true
    return false
  },

  modifyContent (force=false) {
    if (!force && !this.shouldModifyContent()) return
    console.log('modifying content')

    this.updateUrls()
    contentManager.updateContent()
  },

  setLocale (locale_id) {
    if (!locale_id || typeof locale_id !== 'string' || !localeHelper.isValidLocaleId(locale_id)) {
      locale_id = config.default_locale_id
    }

    locale_id = locale_id.toLowerCase()

    this.setLocaleId = locale_id
    cookieManager.setCookie(locale_id)
    this.modifyContent(true)
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
      self.setLocale(this.value)
    }
  },

  setRegionSelectorValue () {
    const selector = this.getRegionSelectorNode();
    const newLocaleId = this.getCurrentLocaleId();
    console.log(`@setRegionSelectorValue, value: ${selector.value}, current: ${this.getCurrentLocaleId()}, shouldModify: ${this.shouldModifyContent()}`)
    if (!this.shouldModifyContent()) return
    if (this.getCurrentLocaleId() === config.default_locale_id) return // don't set a global cookie when the page loads
    if (selector.value === this.getCurrentLocaleId()) return

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
    console.log(`@setCookieFromRegionSelector, value: ${selector.value}, current: ${this.getCurrentLocaleId()}`)
    if (selector.value === config.default_locale_id) return // don't set a global cookie when the page loads
    this.setLocale(selector.value)
  },
}

;(() => {
  document.addEventListener('DOMContentLoaded', () => {
    localization.onLoad()
  })
})()
