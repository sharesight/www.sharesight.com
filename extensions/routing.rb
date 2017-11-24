module Middleman
  class Routing < Extension
    def initialize(app, options_hash={}, &block)
      super
    end

    def after_configuration
      route()
      proxy_pages()
      sitemaps()
    end

    private

    def sitemaps()
      app.data.locales.each do |locale|
        app.config[:locale_obj] = locale
        app.proxy "/#{locale[:id]}/sitemap.xml", "sitemap.xml", :locals => { locale_obj: locale }, ignore: false
      end
    end

    def route()
      # Routing Overrides
      app.page '/*.xml', layout: false
      app.page '/*.json', layout: false
      app.page '/*.txt', layout: false
      app.page "google1decda79799cf179.html", directory_index: false # keeps the .html
    end

    def proxy_pages()
      # pages from data/locales.json
      app.data.locales.each do |locale|
        app.config[:locale_obj] = locale
        locale.pages.select{ |page| page.proxy.nil? || page.proxy == true }.each do |page|
          path = ''
          path += "/#{locale.id}" if locale.id != app.default_locale_id
          path += "/#{page[:page]}" if page[:page] != 'index'
          path += '/index.html'

          app.proxy path, "page-#{page[:page]}.html", :locals => { locale_obj: locale }, ignore: true
        end
      end
    end
  end
end

::Middleman::Extensions.register(:routing, ::Middleman::Routing)
