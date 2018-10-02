# This normalizes the data coming from contentful.
class BlogPostMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super

    keys = entry.fields_with_locales.keys
    unless keys.include?(:slug)
      context.slug = context.title&.downcase.urlize.squeeze('-') # Adds url slugs if they don't exist.
    end

    context.title = context.title&.to_s.squeeze(' ').strip # An author enters ' Great   Title!' and it becomes 'Great Title!'

    # some sanitizing of blog content
    context.content = (context.content || '')
      .gsub('.png)', '.png?w=950)') # restrict image width
      .gsub('.jpg)', '.jpg?w=950)')
      .gsub('//images.contentful.com/', '//images.ctfassets.net/') # redirect old assets
      .gsub('//assets.contentful.com/', '//assets.ctfassets.net/') # see: https://www.contentful.com/blog/2017/12/08/change-of-the-contentful-asset-domain/
      .gsub('//downloads.contentful.com/', '//downloads.ctfassets.net/')
      .gsub('//videos.contentful.com/', '//videos.ctfassets.net/')
  end
end
