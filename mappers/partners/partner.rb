# This normalizes the data coming from contentful.  It's more of a Proof of Concept.

# WARNING: localized fields require a localize mapping!

class PartnersPartnerMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    keys = entry.fields_with_locales.keys

    if keys.include?(:name)
      context.name = map_locales(context.name){ |value| value&.to_s.squeeze(' ').strip } rescue entry.name
    end
  end

  def map_locales(entry, &block)
    # TODO: Maybe take some of the logic from contentful_middleman/mappers

    return block.call(entry) unless entry.is_a?(::Hash)
    mapped_entry = ::Thor::CoreExt::HashWithIndifferentAccess.new
    entry.each do |field, value|
      mapped_entry[field] = block.call(value)
    end

    return mapped_entry
  end
end
