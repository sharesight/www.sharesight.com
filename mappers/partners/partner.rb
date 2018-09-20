# This normalizes the data coming from contentful.  It's more of a Proof of Concept.

# WARNING: localized fields require a localize mapping!

class PartnersPartnerMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    keys = entry.fields_with_locales.keys

    if keys.include?(:name)
      context.name = map_locales(context.name){ |value| value&.to_s.squeeze(' ').strip } rescue entry.try(:name)
    end

    if keys.include?(:priority)
      # There must be a priority of 0 at all times and it's a bit tricky to ensure it's set via the Contentful UI.
      if context.priority.is_a?(::Hash) && !context.priority.try(:en)
        context.priority[:en] = 0
      end

      context.priority = map_locales(context.priority){ |value| value || 0 } rescue entry.try(:priority)
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
