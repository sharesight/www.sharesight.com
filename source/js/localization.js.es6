//= require "./config"
//= require "./helpers/cookies"
//= require "./helpers/content"
//= require "./helpers/locale"
//= require "./helpers/page"
//= require "./helpers/url"

const localization = {
  current_locale_id: localeHelper.getCookieLocale(),

  beforeLoad: function () {
    this.localizeCurrentPath()
  },

  onLoad: function () {
    this.regionSelector()
    this.modifyContent()
  },

  shouldModifyContent: function () {
    if (window.location.pathname.match(/^\/?blog/)) return true
    if (document.getElementById('_404')) return true
    if (localeHelper.current_locale_path_id() !== this.current_locale_id) return true
    return false
  },

  modifyContent: function () {
    if (this.shouldModifyContent()) {
      this.updateUrls()
      contentManager.updateContent()
    }
  },

  localizeCurrentPath: function () {
    // see if the user's raw cookie exists and matches our current path
    if (cookieManager.getCookie() && localeHelper.current_locale_path_id() === cookieManager.getCookie()) return true
    if (cookieManager.getCookie()) return urlHelper.redirect()

    let xhr = new XMLHttpRequest()
    xhr.onreadystatechange = () => {
      if (xhr.readyState !== XMLHttpRequest.DONE) return
      if ([200, 301, 302, 304].indexOf(xhr.status) === -1) return

      const country_code = JSON.parse(xhr.responseText).country.toLowerCase()
      this.setLocale(country_code)
    }

    xhr.open("GET", config.location_url, true)
    xhr.setRequestHeader("Content-Type", "text/plain")
    xhr.send()
  },

  setLocale: function (locale_id) {
    if (!locale_id || typeof locale_id.toLowerCase !== 'function' || !localeHelper.isValidLocaleId(locale_id)) {
      locale_id = config.default_locale_id
    }

    locale_id = locale_id.toLowerCase()

    this.current_locale_id = locale_id
    cookieManager.setCookie(locale_id)
    let redirected = urlHelper.redirect(locale_id)
    if (redirected !== true) this.modifyContent() // because redirection may not always happen
  },

  updateUrls: function () {
    ;[].concat.apply([], [ // flatten
        document.querySelectorAll(`a[href^="${config.base_url}"]`), // absolute urls
        document.querySelectorAll(`a[href^="${config.help_url}"]`), // help site
        document.querySelectorAll(`a[href^="${config.base_path}"]`), // relative urls
      ].map(elements => Array.from(elements))
    ).forEach((element) => {
      element.pathname = urlHelper.localizePath(element.pathname)
    })
  },

  regionSelector: function () {
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
  localization.beforeLoad()

  document.addEventListener('DOMContentLoaded', () => {
    localization.onLoad()
  })
})()
