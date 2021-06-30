# frozen_string_literal: true

require 'mappers/blog/post'
require 'mappers/partners/partner'
require 'mappers/landing-pages/page'

# Schema defines mapping.
# A schema can be either a string 'author' or an array ['author', AuthorMapper].
# In both cases, 'author' means it will take the 'author' from Contentful and put it into 'data/space/authors' (uses pluralize)
# in the Array case, AuthorMapper will be ran over every entry to normalize or map the data.

module ContentfulConfig
  module BlogSpace
    NAME = 'blog'
    SPACE_ID = '91sm3pewxzag'
    ACCESS_TOKEN = ENV['CONTENTFUL_BLOG_ACCESS_TOKEN'] # For Published Content
    PREVIEW_ACCESS_TOKEN = ENV['CONTENTFUL_BLOG_PREVIEW_TOKEN'] # For All, Unpublished: Draft Content
    CDA_QUERY = {}.freeze
    ALL_ENTRIES = true
    PAGINATION_SIZE = 500 # This must result in an API response of <7mb, else the gem or API throws an error.

    SCHEMAS = [
      { name: 'post', mapper: ::BlogPostMapper },
      'category',
      'author'
    ].freeze
  end

  module PartnersSpace
    NAME = 'partners'
    SPACE_ID = 'rafbawofr5bl'
    ACCESS_TOKEN = ENV['CONTENTFUL_PARTNERS_ACCESS_TOKEN'] # For Published Content
    PREVIEW_ACCESS_TOKEN = ENV['CONTENTFUL_PARTNERS_PREVIEW_TOKEN'] # For All, Unpublished: Draft Content
    CDA_QUERY = { locale: '*' }.freeze
    ALL_ENTRIES = true
    PAGINATION_SIZE = 500

    SCHEMAS = [
      { name: 'partner', mapper: ::PartnersPartnerMapper },
      'category'
    ].freeze
  end

  module LandingPagesSpace
    NAME = 'landing-pages'
    SPACE_ID = 'cbgsdqa84fjb'
    ACCESS_TOKEN = ENV['CONTENTFUL_LANDING_PAGES_ACCESS_TOKEN'] # For Published Content
    PREVIEW_ACCESS_TOKEN = ENV['CONTENTFUL_LANDING_PAGES_PREVIEW_TOKEN'] # For All, Unpublished: Draft Content
    CDA_QUERY = { locale: '*' }.freeze
    ALL_ENTRIES = true

    # TODO: This needs to be lowered, else we will reach the limit of ~7mb of data download eventually.
    # Right now, we MUST grab ALL Entries in the same API request as they are not referenced correctly.
    # Without this, sometimes we get buttons that just look like { id: 12345 } without the nested data.
    # I believe this is because our `contentful_middleman` gem is not correctly mapping references between paginated datasets.
    # NOTE: If we exceed >1000 Entries of >7mb of Landing Page Entry Data, this will break, 100%!
    PAGINATION_SIZE = 1000

    SCHEMAS = [
      { name: 'page', mapper: ::LandingPagesPageMapper },
      'section',
      'button',
      'content'
    ].freeze
  end
end
