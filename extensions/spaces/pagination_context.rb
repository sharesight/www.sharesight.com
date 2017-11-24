require 'middleman-core'

module Middleman
  module Spaces
    class PaginationContext < OpenStruct
      extend Forwardable
      include Enumerable

      attr_accessor :set
      attr_accessor :per_page
      attr_accessor :current_page
      attr_accessor :total_pages
      attr_accessor :from_items
      attr_accessor :to_items
      attr_accessor :total_items
      attr_accessor :index_page
      attr_accessor :next_page
      attr_accessor :prev_page

      def initialize(set: {}, per_page: 16, total_pages: 1, current_page: 1, total_items: 1, index_page:, next_page:, prev_page:)
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
