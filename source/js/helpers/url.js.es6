//= require "./locale"
//= require "./page"

const urlHelper = {
  shouldLocalizePath: function (path = window.location.pathname, locale_id) {
    if (path.match(/^\/?blog/)) return false
    if (path.match(/^\/?404/)) return false

    // page exists, but not in the desired locale, eg. from ca/lp-general-ca to [non-existent] [global]/lp-general-ca
    if (pageHelper.isPage(path) && !pageHelper.getPage(path, locale_id)) {
      return false
    }

    return true
  },

  // we've very redundant in these adding and removing slashes.
  // For delete[0], etc., to be accurate accessors, we have to add/remove/squeeze slashes a lot!
  removeLocalizationFromPath: function(path) {
    path = '/' + path // force path to start with a slash
    path = path.replace(/\/+/g, '/') // trim all double slashes
    let split = path.split('/')

    // remove any valid locales or the current locale (via cookie, which could be an invalid locale) from the path
    if (localeHelper.isValidLocaleId(split[0]) || split[0] === localization.current_locale_id) {
      delete split[0]
    } else if (!split[0] && (localeHelper.isValidLocaleId(split[1]) || split[1] === localization.current_locale_id)) {
      delete split[1]
    }

    path = '/' + split.join('/')
    path = path.replace(/\/+/g, '/') // trim all double slashes

    return path
  },

  getUnlocalizedPath: function(path = window.location.pathname) {
    if (!path || path.indexOf('/') === -1) return path

    // split and grab first string; may be undefined
    return this.removeLocalizationFromPath(path).split('/')[1] || 'index'
  },

  localizePath: function (input = '', locale_id = localization.current_locale_id) {
    if (!this.shouldLocalizePath(input, locale_id)) return input
    if (locale_id == config.default_locale_id) locale_id = ''
    if (!localeHelper.isValidLocaleId(locale_id)) locale_id = ''
    let path = this.removeLocalizationFromPath(input)

    path = `/${locale_id}/${path}`
    path = path.replace(/\/+/g, '/') // roughly trim down all duplicate slashes // => /
    return path
  }
}
