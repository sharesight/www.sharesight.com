module BasicHelper
  # Converts "Sharesight & Xero Are Magical!" => "sharesight-xero-are-magical!"
  # NOTE: Must keep the same formatting as we used to – no replacing !@#$%^&*()… as that could break older posts?
  # TODO: Validate we can't strip out non-alphanumerics by looking at these strings.
  def self.url_friendly_string(str)
    return str&.urlize&.gsub('& ', '')&.gsub(' ', '-')&.gsub('--', '-')&.downcase
  end

  # Parsing out quotes for contentful => html.
  def self.replace_quotes(str)
    str&.gsub(/"/, "'")
  end
end
