//= require "./locale"
//= require "./page"

const urlHelper = {
  shouldLocalizePath: function (path = window.location.pathname, locale_id) {
    if (path.match(/^\/?blog/)) return false
    if (path.match(/^\/?404/)) return false

    // page exists, but not in the desired locale (NOTE: This should not happen!)
    if (pageHelper.isPage(path) && !pageHelper.getPage(path, locale_id)) {
      return false
    }

    return true
  },

  shouldLocalizeUrl: function(url, locale_id) {
    // Our help site doesn't support locale 'us'
    if (locale_id == 'us' && url.match(/http(s)?:\/\/help\.sharesight\.com/)) return false

    return true
  },

  // we've very redundant in these adding and removing slashes.
  // For delete[0], etc., to be accurate accessors, we have to add/remove/squeeze slashes a lot!
  removeLocalizationFromPath: function(path) {
    path = '/' + path // force path to start with a slash
    path = path.replace(/\/+/g, '/') // trim all double slashes
    let split = path.split('/')

    // remove any valid locales from the path
    if (localeHelper.isValidLocaleId(split[0])) {
      delete split[0]
    } else if (!split[0] && localeHelper.isValidLocaleId(split[1])) {
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

  getLocalisationFromPath: function(path = window.location.pathname) {
    if (!path || path.indexOf('/') === -1) return path

    path = '/' + path // force path to start with a slash
    path = path.replace(/\/+/g, '/') // trim all double slashes
    let split = path.split('/')

    if (localeHelper.isValidLocaleId(split[1])) return split[1]

    return "global"
  },

  localizePath: function (path, locale_id) {
    if (!this.shouldLocalizePath(path, locale_id)) return path
    if (locale_id == config.default_locale_id) locale_id = ''
    if (!localeHelper.isValidLocaleId(locale_id)) locale_id = ''
    let path = this.removeLocalizationFromPath(path)

    path = `/${locale_id}/${path}`
    path = path.replace(/\/+/g, '/') // roughly trim down all duplicate slashes // => /
    return path
  }
}
