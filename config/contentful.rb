require 'mappers/partners/partner'

# Schema defines mapping.
# A schema can be either a string 'author' or an array ['author', AuthorMapper].
# In both cases, 'author' means it will take the 'author' from Contentful and put it into 'data/space/authors' (uses pluralize)
# in the Array case, AuthorMapper will be ran over every entry to normalize or map the data.

module ContentfulConfig
	module PartnersSpace
		NAME = 'partners'
		SPACE_ID = 'rafbawofr5bl'
		ACCESS_TOKEN = ENV['CONTENTFUL_PARTNERS_ACCESS_TOKEN'] # For Published Content
		PREVIEW_ACCESS_TOKEN = ENV['CONTENTFUL_PARTNERS_PREVIEW_TOKEN'] # For All, Unpublished: Draft Content
		CDA_QUERY = { locale: '*' }
		ALL_ENTRIES = true
		PAGINATION_SIZE = 500

		SCHEMAS = [
			{ name: 'partner', mapper: ::PartnersPartnerMapper },
			'category'
		]
	end
end
