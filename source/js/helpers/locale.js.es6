//= require "../config"
// requires cookieHelper; not including due to circular dependency

const localeHelper = {
  getCookieLocale: function () {
    let locale = cookieManager.getCookie()

    if (!localeHelper.isValidLocaleId(locale)) locale = config.default_locale_id
    return locale
  },

  getLocale: function (locale_id = localization.getCurrentLocaleId()) {
    const locale = config.locales.find(locale => locale.id === locale_id)
    if (locale) return locale

    // else return default locale
    return config.locales.find(locale => locale.id === config.default_locale_id)
  },

  isValidLocaleId: function (locale_id) {
    if (!locale_id || typeof locale_id.toLowerCase !== 'function') return false
    locale_id = locale_id.toLowerCase()
    return config.locale_ids.indexOf(locale_id) > -1
  }
}
