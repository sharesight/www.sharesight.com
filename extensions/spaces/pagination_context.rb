# frozen_string_literal: true

require 'middleman-core'

module Middleman
  module Spaces
    class PaginationContext < OpenStruct
      extend Forwardable
      include Enumerable

      attr_accessor :set, :per_page, :current_page, :total_pages, :from_items, :to_items, :total_items, :index_page,
                    :next_page, :prev_page

      def initialize(index_page:, next_page:, prev_page:, set: {}, per_page: 16, total_pages: 1, current_page: 1, total_items: 1)
        @set = set
        @per_page = per_page
        @total_pages = total_pages
        @current_page = current_page
        @index_page = index_page
        @next_page = next_page
        @prev_page = prev_page

        @from_items = ((current_page - 1) * per_page) + 1
        @to_items = current_page * per_page
        @total_items = total_items
      end

      def each(&block)
        set.each(&block)
      end
    end
  end
end
