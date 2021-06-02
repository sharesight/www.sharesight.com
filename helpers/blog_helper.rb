module BlogHelper
  # Use url_friendly_string for non-posts; may be able to phase this out..
  # Try to switch over to super.url_slug, if possible!
  def self.url_slug(post)
    # This is Split out for Testing Purposes.
    return post.url_slug if post&.url_slug&.present?
    return url_slug_from_title(post&.title)
  end

  def self.url_slug_from_title(title)
    # Using this original version for SEO purposes – don't want to update urls to new ones.
    return title&.to_s.strip.downcase.urlize.gsub('--', '-')
  end

  def self.is_valid_post?(post)
    return !!(
      post && !post[:author].blank? && !post[:title].blank? && !post[:featured_image].blank? && !self.url_slug(post).empty?
    ) rescue false
  end

  def self.is_valid_category?(category)
    return !!(
      category && !category[:name].blank?
    ) rescue false
  end
end
