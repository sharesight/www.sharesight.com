//= require "../config"
// requires localeHelper; not including due to circular dependency

const cookieManager = {
  cookieName: 'ss_geo_redir',
  cookie: null,
  cookieArray: [],

  getCookie: function (cache = true) {
    if (cache && this.cookie) return this.cookie
    this.readCookies()

    const pattern = RegExp("^\\s*"+this.cookieName+"=\\s*(.*?)\\s*$")

    // WARNING: This could return multiple cookies, in theory?
    this.cookie = this.cookieArray
      .filter(cookie => cookie.match(pattern) && cookie.match(pattern)[1])
      .map(cookie =>
        cookie.match(pattern)[1].toLowerCase().replace('gb', 'uk') // for old cookies
      )
      .toString()

    return this.cookie
  },

  setCookie: function (value) {
    let d = new Date()
    d.setTime(d.getTime() + (180*24*60*60*1000))
    const expires = "expires="+ d.toUTCString()

    document.cookie = this.cookieName + "=" + value + ";path=/;" + expires
    this.cookie = value
  },

  readCookies: function () {
    this.cookieArray = document.cookie.split(';')
  }
}
