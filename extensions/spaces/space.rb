require 'middleman-core'
require 'contentful_middleman/helpers'
require 'date'

load 'helpers/basic_helper.rb'
load 'extensions/spaces/pagination_context.rb'

module Middleman
  module Spaces
    class Base < Middleman::Extension
      include ::ContentfulMiddleman::Helpers # grabs localize_entry

      attr_accessor :space

      def initialize(app, options_hash={}, &block)
        super
        @resources = []
        @space = nil
        @paginated_collection = nil
        @paginated_model = nil
        @paginated_model_entry = :name # "Entry Title" from Contentful
        @categories_collection = 'categories'
        @categories_model_entry = :name # "Entry Title" from Contentful
        @index_category = 'All'
        @index_path = nil # this has a better default in after_configuration
        @index_path = '' # automatically generated in after_configuration
        @index_page_file = nil
        @per_page = 16
        @localize = false
        @processed_collections = {}
      end

      def after_configuration
        @index_path = @index_path.gsub(/\/$/, '') || "#{space}/#{BasicHelper::url_friendly_string(@index_category)}"
        @index_slug = @index_path.gsub(/^#{space}\/?/, '')

        if has_contentful_data?
          get_locales_array.each do |locale_obj|
            proxy_index_page(locale_obj)
            proxy_category_pages(locale_obj)
            proxy_individual_pages(locale_obj)
          end
        end
      end

      private

      # Generate all Individual Blog Pages
      def proxy_individual_pages(locale_obj)
        paginated_collection(locale_obj[:lang]).each do |model|
          next unless is_valid_paginated_model?(model)
          app.proxy path_for_proxy("#{space}/#{url_slug(model)}", locale_obj[:id]), "/#{space.downcase}/individual.html", locals: {
            @paginated_model.to_sym => model,
            locale_obj: locale_obj
          }, ignore: true
        end
      end

      def process_collection_by_name(name, lang)
        @processed_collections = {} if !@processed_collections
        @processed_collections[name] = {} if name && !@processed_collections&.dig(name)
        return @processed_collections[name][lang] if @processed_collections&.dig(name, lang)
        return @processed_collections[name][lang] = process_collection(app.data[space][name], lang)
      end

      def process_collection(collection, lang)
        collection = collection.map{ |tuple| tuple[1] } # contentful passes ["id", { ... }]
        collection = collection.map{ |model| localize_entry(model, lang, default_locale_obj[:lang]) } if @localize
        collection = collection.sort{ |a,b| sort_pagination(a, b) }
      end

      def paginated_collection(lang = default_locale_obj[:lang])
        collection = process_collection_by_name(@paginated_collection, lang)
        collection = collection.select{ |model| is_valid_paginated_model?(model) }
        return collection
      end

      def categories_collection(lang = default_locale_obj[:lang])
        collection = process_collection_by_name(@categories_collection, lang)
        collection = collection.select{ |model| is_valid_category_model?(model) }
        return collection
      end

      def categories_list(lang = default_locale_obj[:lang], withIndex: true)
        collection = paginated_collection(lang)
        categories = []

        if withIndex == true
          categories.push({
            id: @index_category&.downcase,
            name: @index_category,
            description: nil,
            path: @index_path,
            url_slug: @index_slug,
            count: collection.length,
            set: collection
          })
        end

        categories_collection(lang).each do |category|
          set = collection.select { |model|
            # models that have the category id
            model[@categories_collection.to_sym]&.find{ |model_category| model_category[:id].include?(category[:id]) }
          }

          categories.push({
            id: category[:id],
            name: category[:name],
            description: category[:description],
            _meta: category[:_meta],
            path: "#{space}/#{category_slug(category)}",
            url_slug: category_slug(category),
            count: set.length,
            set: set
          })
        end

        return categories
      end

      # No pagination or anything on the index page; eg. partners/featured.html
      def proxy_index_page(locale_obj)
        return unless @index_page_file

        file_path = "/#{space}/#{@index_page_file}"

        resource = ::Middleman::Sitemap::Resource.new(
          app.sitemap,
          path_for_proxy(space, locale_obj[:id]),
          file_path
        )

        locals = { locale_obj: locale_obj }
        resource.add_metadata(locals) # might be irrelevant as we're adding them below

        app.proxy resource.path, resource.source_file, locals: locals, ignore: true
      end

      def proxy_category_pages(locale_obj)
        file_path = "/#{space}/paginated.html"

        categories_list(locale_obj[:lang]).each do |category|
          per_page = @per_page
          total_pages = (category[:set].length.to_f / per_page).ceil

          # Iterate through to generate the page resources, nothing more.
          # We need a list of resources so we can have prev_page and next_page context.
          page_num = 1
          resources = []
          while page_num <= total_pages do
            resources.push(::Middleman::Sitemap::Resource.new(
              app.sitemap,
              paginated_path(category[:path], page_num, locale_obj[:id]),
              file_path
            ))
            page_num += 1
          end

          # Iterate through created resources, add metadata, those proxy pages.
          resources.each_with_index do |resource, index|
            page_num = index + 1
            current_set = category[:set].drop(per_page * index).take(per_page)

            pagination = PaginationContext.new(
              set: current_set,
              per_page: per_page,
              total_pages: total_pages,
              total_items: category[:set].length,
              current_page: page_num,
              index_page: resources[0],
              next_page: index < total_pages ? resources[index + 1] : nil,
              prev_page: index > 0 ? resources[index - 1] : nil
            )

            locals = { category: category, pagination: pagination, locale_obj: locale_obj }
            resource.add_metadata(locals) # might be irrelevant as we're adding them below

            app.proxy resource.path, resource.source_file, locals: locals, ignore: true
          end
        end
      end

      def path_for_proxy(slug, locale_id)
        return paginated_path(slug, nil, locale_id)
      end

      def paginated_path(path, page_num = 1, locale_id)
        base = (locale_id != default_locale_id) ? "#{locale_id}/" : ''

        newPath = "#{base}/#{path}"
        newPath += "/pages/#{page_num}" if !page_num.nil? && page_num > 1 # only pages > 1 use path/pages/2.html links; else path.html

        newPath += '.html'
        newPath = newPath.squeeze('/')
        return newPath
      end

      def url_slug(model)
        return model[:url_slug] || BasicHelper::url_friendly_string(model[@paginated_model_entry.to_sym])
      end

      def category_slug(model)
        return model[:url_slug] || BasicHelper::url_friendly_string(model[@categories_model_entry.to_sym])
      end

      def sort_pagination(a, b)
        a_time = !a[:created_at].nil? ? a[:created_at] : Time.now
        b_time = !b[:created_at].nil? ? b[:created_at] : Time.now
        b_time <=> a_time
      end

      def has_contentful_data?
        return app.data.respond_to?(space.to_sym) && !app.data[space.to_sym][@paginated_collection.to_sym].nil? && !app.data[space.to_sym][@categories_collection.to_sym].nil?
      end

      # Extended by Child Class.
      def is_valid_paginated_model?(model)
        return model
      end

      # Extended by Child Class.
      def is_valid_category_model?(model)
        return model
      end

      # This is a helper to return only the default locale (eg. no localization) or the full list, depending on @localize
      def get_locales_array
        return app.data.locales if @localize
        return [ default_locale_obj ]
      end

      # The default|get_locale_* are from helpers/middleman/helpers; no way to inject them in as they don't have access to app.
      def default_locale_id
        return app.config[:default_locale_id]
      end

      def default_locale_obj
        return app.default_locale_obj
      end

      def get_locale_obj(locale_id)
        return app.get_locale_obj(locale_id)
      end
    end
  end
end
