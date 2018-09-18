# This normalizes the data coming from contentful.  It's more of a Proof of Concept.

# WARNING: localized fields require a localize mapping!

class LandingPagesPageMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super
    keys = entry.fields_with_locales.keys

    if keys.include?(:layout)
      context.layout = map_locales(context.layout) do |layout|
        case layout
        when 'default'
          'layout'
        when 'index'
          'layout_index'
        when 'pro'
          'layout_pro'
        when 'blog_post'
          'blog_post'
        else
          layout
        end
      end rescue entry.layout
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
