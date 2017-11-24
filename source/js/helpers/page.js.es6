//= require "./locale"

const pageHelper = {
  getCurrentPage: function (){
    let path = window.location.pathname
    return this.getPage(path) || this.getPageFromAnyLocale(path)
  },

  isPage: function(name) {
    return this.getPageFromAnyLocale(name)
  },

  getPageFromAnyLocale: function(name) {
    name = urlHelper.getUnlocalizedPath(name)
    const getPage = (locale) => locale.pages.find(page => page.page === name)

    const locale = config.locales.find(getPage) // find locale with the page on it

    return locale ? getPage(locale) : undefined // find the page itself
  },

  getPage: function(name, locale_id = localization.current_locale_id) {
    name = urlHelper.getUnlocalizedPath(name)
    return localeHelper.getLocale(locale_id).pages.find(page => page.page === name)
  }
}
