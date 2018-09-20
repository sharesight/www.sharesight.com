# This normalizes the data coming from contentful.
class BlogPostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    keys = entry.fields_with_locales.keys
    unless keys.include?(:slug)
      context.slug = context.title&.downcase.urlize.squeeze('-') # Adds url slugs if they don't exist.
    end

    context.title = context.title&.to_s.squeeze(' ').strip # An author enters ' Great   Title!' and it becomes 'Great Title!'
  end
end
