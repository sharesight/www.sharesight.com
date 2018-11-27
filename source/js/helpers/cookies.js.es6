//= require "../config"
// requires localeHelper; not including due to circular dependency

const cookieManager = {
  cookieName: 'sharesight_country',
  cookie: null,

  getCookie (cache = true) {
    if (cache && this.cookie) return this.cookie

    const pattern = RegExp(`^\\s*${this.cookieName}\\s*=\\s*(.*?)\\s*$`)

    // WARNING: This could return multiple cookies, in theory.
    this.cookie = this.getAllCookies()
      .map(cookie => cookie.match(pattern) && cookie.match(pattern)[1])
      .filter(cookie => cookie) // filter out undefines
      .toString()

    return this.cookie
  },

  setCookie (value) {
    let d = new Date()
    d.setTime(d.getTime() + (180*24*60*60*1000)) // 180 days

    console.log("set cookie " + `${this.cookieName}=${value}`);
    document.cookie = `${this.cookieName}=${value};path=/;expires=${d.toUTCString()}`
    this.cookie = value
  },

  getAllCookies () {
    return document.cookie.split(';')
  }
}
