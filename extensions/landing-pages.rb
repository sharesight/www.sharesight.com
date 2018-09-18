require 'middleman-core'
require 'contentful_middleman/helpers'
require 'date'

load 'helpers/basic_helper.rb'

module Middleman
  module Spaces
    class LandingPages < Middleman::Extension
      include ::ContentfulMiddleman::Helpers # grabs localize_entry

      def after_configuration
        if has_contentful_data? # this file will be ran before data is loaded, so we should protect it
          app.data.locales.each do |locale_obj|
            proxy_landing_pages(locale_obj)
          end
        end
      end

      private

      # Generate all Landing Pages
      def proxy_landing_pages(locale_obj)
        process_collection(locale_obj[:lang]).each do |model|
          app.proxy(
            path_for_proxy(model.url_slug, locale_obj[:id]),
            "/landing-pages/template.html",
            locals: model.merge({ locale_obj: locale_obj }).with_indifferent_access,
            layout: model.layout || 'layout',
            ignore: true
          )
        end
      end

      def process_collection(lang)
        collection = app.data['landing-pages'].pages
        collection = collection.map{ |tuple| tuple[1] } # contentful passes ["id", { ... }]
        collection = collection.map{ |model| localize_entry(model, lang, default_locale_obj[:lang]) }
        return collection
      end

      def has_contentful_data?
        return app.data.respond_to?('landing-pages') && !app.data['landing-pages'].pages.nil?
      end

      def path_for_proxy(slug, locale_id)
        base = (locale_id != default_locale_id) ? "#{locale_id}/" : ''
        path = "#{base}/#{slug}"

        path += '.html'
        return path.squeeze('/')
      end

      def default_locale_id
        return app.config[:default_locale_id]
      end

      def default_locale_obj
        return app.default_locale_obj
      end
    end
  end
end

::Middleman::Extensions.register(:landing_pages_space, ::Middleman::Spaces::LandingPages)
