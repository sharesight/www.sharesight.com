# This normalizes the data coming from contentful, so a user enters ' Great   Title!' and it becomes 'Great Title!'
# Adds url slugs.
class BlogPostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super
    context.title = context.title&.to_s.squeeze(' ').strip
    context.slug = context.title&.downcase.urlize.squeeze('-')
  end
end
