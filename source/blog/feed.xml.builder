xml.instruct!
xml.rss version: "2.0", 'xmlns:dc' => "http://purl.org/dc/elements/1.1/", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Sharesight Blog"
    xml.description "Perfect Share Portfolio Management"
    xml.link base_url()
    xml.tag! 'atom:link', href: base_url('/blog/feed.xml'), rel: 'self', type: 'application/rss+xml'
    xml.language "en-US"

    number_of_items = 10
    data.blog.posts.keys[-number_of_items..-1].reverse.each do |key|
      post = data.blog.posts[key]
      next if post.title.blank?
      xml.item do
        url = post_url(post)
        author = post&.author&.display_name || "Sharesight Staff"

        description = post[:content].to_s
        # use full image urls
        description.gsub!(/\(\/\//, '(https://')
        # remove script tags, etc.
        description = Rails::Html::WhiteListSanitizer.new.sanitize(description)

        xml.title post.title
        xml.link url
        xml.description {
          xml.cdata!(
            partial("partials/components/markdown", locals: { markdown: description, inline: true })
          )
        }
        xml.pubDate Time.parse((!post[:created_at].blank? ? post[:created_at] : Time.now).to_s).rfc822
        xml.dc :creator, author
        post&.categories&.each do |category|
          category_name = data.blog.categories.send(category[:id])&.dig(:name)
          xml.category category_name if category_name
        end
        xml.guid url
      end
    end
  end
end
