//= require "./config"
//= require "./helpers/cookies"
//= require "./helpers/content"
//= require "./helpers/locale"
//= require "./helpers/page"
//= require "./helpers/url"

const localization = {
  current_locale_id: localeHelper.getCookieLocale(),

  onLoad () {
    this.initializeRegionSelector()
    this.modifyContent()
  },

  shouldModifyContent () {
    if (window.location.pathname.match(/^\/?blog/)) return true
    if (document.getElementById('_404')) return true
    return false
  },

  modifyContent () {
    if (!this.shouldModifyContent()) return

    this.updateUrls()
    contentManager.updateContent()
  },

  setLocale (locale_id) {
    if (!locale_id || typeof locale_id !== 'string' || !localeHelper.isValidLocaleId(locale_id)) {
      locale_id = config.default_locale_id
    }

    locale_id = locale_id.toLowerCase()

    this.current_locale_id = locale_id
    cookieManager.setCookie(locale_id)
    this.modifyContent()
  },

  updateUrls () {
    ;[].concat.apply([], [ // flatten
        document.querySelectorAll(`a[href^="${config.base_url}"]`), // absolute urls
        document.querySelectorAll(`a[href^="${config.help_url}"]`), // help site
        document.querySelectorAll(`a[href^="${config.base_path}"]`), // relative urls
      ].map(elements => Array.from(elements))
    ).forEach((element) => {
      element.pathname = urlHelper.localizePath(element.pathname)
    })
  },

  initializeRegionSelector () {
    const self = this
    const selector = document.getElementById('region_selector')
    if (!selector || !selector.options || !selector.options.length) return

    // first load
    Array.from(selector.options).forEach(option => {
      option.removeAttribute('selected')

      if (option.value.toLowerCase() === self.current_locale_id) {
        option.setAttribute('selected', true)
      }
    })

    // when it changes
    selector.onchange = function () {
      self.setLocale(this.value)
    }
  }
}

;(() => {
  document.addEventListener('DOMContentLoaded', () => {
    localization.onLoad()
  })
})()
