module CapybaraBaseHelpers
  def get_meta(name, name_key: 'name', return_key: :content)
    return get_head('meta', args: { name_key => name }, return_key: return_key)
  end

  def get_head(tagname, args: {}, contains: {}, ends_with: {}, starts_with: {}, return_key:)
    xpath = generate_xpath("//html/head/#{tagname}", args: args, contains: contains, ends_with: ends_with, starts_with: starts_with, ignore: return_key)
    result = find(:xpath, xpath, visible: false)
    return result[return_key]
  end

  def generate_xpath(tagname, text: nil, args: {}, contains: {}, ends_with: {}, starts_with: {}, ignore: nil, visible: true)
    xpath = "#{tagname}"

    xpath += "[text()=\"#{text}\"]" if text && text.is_a?(String) unless 'text' == ignore

    args.each do |key, value|
      xpath += "[@#{key}=\"#{value}\"]" unless key&.to_sym == ignore&.to_sym
    end

    contains.each do |key, value|
      xpath += "[contains(@#{key}, \"#{value}\")]" unless key&.to_sym == ignore&.to_sym
    end

    ends_with.each do |key, value| # ends-with is XPath 2.0
      xpath += "[substring(@#{key}, string-length(@#{key}) - string-length(\"#{value}\") + 1) = \"#{value}\"]" unless key&.to_sym == ignore&.to_sym
    end

    starts_with.each do |key, value|
      xpath += "[starts-with(@#{key}, \"#{value}\")]" unless key&.to_sym == ignore&.to_sym
    end

    return xpath
  end
end
