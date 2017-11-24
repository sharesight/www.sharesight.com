require 'middleman-core'
load 'extensions/spaces/space.rb'
load 'helpers/blog_helper.rb'

module Middleman
  module Spaces
    class Blog < Base
      def initialize(app, options_hash={}, &block)
        super

        @space = 'blog'
        @index_path = 'blog'
        @paginated_collection = 'posts'
        @paginated_model = 'post'
        @paginated_model_entry = :title
      end

      def url_slug(model)
        return BlogHelper.url_slug(model)
      end

      private

      # Logical Helpers
      def is_valid_paginated_model?(model)
        return BlogHelper.is_valid_post?(model)
      end

      def is_valid_category_model?(model)
        return BlogHelper.is_valid_category?(model)
      end
    end
  end
end

::Middleman::Extensions.register(:blog_space, ::Middleman::Spaces::Blog)
