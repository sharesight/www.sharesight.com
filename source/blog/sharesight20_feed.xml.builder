xml.instruct!
xml.rss version: "2.0", 'xmlns:dc' => "http://purl.org/dc/elements/1.1/", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Sharesight20 Feed"
    xml.description "Sharesight20 snapshots look at the top 20 trades on both the ASX and NZX markets by Sharesight users weekly, monthly and yearly."
    xml.link base_url()
    xml.tag! 'atom:link', href: base_url('/blog/sharesight20_feed.xml'), rel: 'self', type: 'application/rss+xml'
    xml.language "en-US"

    if sharesight20_category && sharesight20_category[:set].length > 0 # if it doesn't exist, show nothing
      number_of_items = 10
      number_of_items = sharesight20_category[:set].length if sharesight20_category[:set].length < number_of_items

      sharesight20_category[:set].sort{ |a,b|
        a['created_at'] <=> b['created_at']
      }[-number_of_items..-1].reverse.each do |post|
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
end
