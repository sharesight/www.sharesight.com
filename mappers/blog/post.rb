# This normalizes the data coming from contentful.
class BlogPostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super
    context.title = context.title&.to_s.squeeze(' ').strip # An author enters ' Great   Title!' and it becomes 'Great Title!'
    context.slug = context.slug || context.title&.downcase.urlize.squeeze('-') # Adds url slugs.
  end
end
