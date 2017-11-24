require 'middleman-core'
load 'extensions/spaces/space.rb'
load 'helpers/partner_helper.rb'

module Middleman
  module Spaces
    class Partners < Base
      def initialize(app, options_hash={}, &block)
        super

        @space = 'partners'
        @paginated_collection = 'partners'
        @paginated_model = 'partner'
        @paginated_model_entry = :name
        @per_page = 30
        @localize = true

        # So partners/all goes to all partners (paginated)
        @index_path = "#{space}/#{BasicHelper::url_friendly_string(@index_category)}"

        # So partners/ goes to featured.
        @index_page_file = 'featured.html'
      end

      private

      def sort_pagination(a, b)
        return PartnerHelper.sort_partners(a, b)
      end

      def is_valid_paginated_model?(model)
        return PartnerHelper.is_valid_partner?(model)
      end

      def is_valid_category_model?(model)
        return PartnerHelper.is_valid_category?(model)
      end
    end
  end
end

::Middleman::Extensions.register(:partners_space, ::Middleman::Spaces::Partners)
