load File::expand_path('./locale.rb', __dir__)

module MiddlemanUrlHelpers
  include MiddlemanLocaleHelpers

  def get_current_page_url
    return current_page.url
  end

  def canonical_url
    return absolute_url(get_current_page_url)
  end

  def current_global_url
    # NOTE: This has no localization as we're using the entire `current_page.url` (which may have localization)
    return unlocalized_url(get_current_page_url)
  end

  # This converts from relative to absolute, strips .html, and /index.
  def absolute_url(append = '/', base_url: config[:base_url])
    return append if append&.match(/\A(http[s]?:)?\/\//) # already a url (https://, http://, //)

    append = strip_html_from_path(append)
    append = strip_index_from_path(append)

    append = '' if append == '/' # No trailing slash for base index like `sharesight.com`, but still for `sharesight.com/xero/`.
    return "#{base_url}#{append}"
  end

  # See BasicHelper.
  # NOTE: For Blog Posts, use BlogHelper.url_slug....
  def url_friendly_string(str)
    return BasicHelper::url_friendly_string(str)
  end

  # All of these are pretty much just proxies into localize_url.
  def base_path(append = '/')
    return base_url(append, base_url: '')
  end

  def base_url(append = '/', base_url: config[:base_url])
    return localize_url(append, base_url: base_url, locale_id: default_locale_id)
  end

  def unlocalized_url(append = '/', base_url: config[:base_url])
    return base_url(append, base_url: base_url)
  end

  def unlocalized_path(append = '/')
    return base_path(append)
  end

  def localize_path(append = '/', locale_id: current_locale_id)
    return localize_url(append, locale_id: locale_id, base_url: '')
  end

  def localize_url(append = '/', locale_id: current_locale_id, base_url: config[:base_url])
    locale_id ||= current_locale_id
    locale_id = locale_id.downcase if locale_id
    page = page_from_path(append)

    raise ArgumentError.new("Attempted to localize a url that already has a scheme: #{append}.") if append&.match(/\A(http[s]?:)?\/\//) # already a url (https://, http://, //)

    if (base_url == config[:base_url] || base_url == '') && is_valid_page?(page) && !is_valid_locale_id_for_page?(page, locale_id)
      # If we're passed a locale id that isn't valid for this page, let's see if we can get a valid one!
      locale_id = get_page_base_locale(page_from_path(append))[:id]

      # Only raise this for local paths with a page and locale id applicable..
      raise ArgumentError.new("Attempted to localize a path to an unsupported locale: #{locale_id} for page: #{page}.") if !is_valid_locale_id_for_page?(page, locale_id)
    end

    raise ArgumentError.new("Attempted to localize a path to an invalid locale: #{locale_id}.") if !is_valid_locale_id?(locale_id)

    append = strip_html_from_path(append)
    append = strip_locale_from_path(append)
    append = strip_index_from_path(append)

    # Set no locale, default locale, or unlocalized pages to have no locale path..
    if !locale_id || locale_id == default_locale_id || is_unlocalized_page?(page)
      append = '' if append == '/' # Just incase.  No trailing slash for empty appends, like `sharesight.com`, but still for `sharesight.com/xero/`.
      return "#{base_url}#{append}"
    end

    base_url = "#{base_url}/" if base_url

    return "#{base_url}#{locale_id}#{append}"
  end

  def page_from_path(path)
    path = strip_locale_from_path(path)
    split = path&.split('/') || []

    return 'index' if split.length == 0 # this is with locale removed

    i = 0
    while (i < split.length) do
      return split[i] if !split[i].blank?
      i += 1
    end

    return nil # (shouldn't actually reach this point – it would have to be an array of blanks, which shouldn't happen via split)
  end

  def wrap_path_in_slashes(path)
    # ensure append is wrapped in singular forward slashes
    path = "/#{path}"
    path = "#{path}/" if !['#', '?', '&', '.'].any? { |needle| path&.split('/')&.last&.include?(needle) } # does not have a #foo, ?foo, or &foo in the last portion of the url
    return path.squeeze('/') # Adjacent multiple slashes should always resolve to a single slash as per HTTP RFC.
  end

  def trim_wrapped_slashes(path)
    return path.gsub(/^\/+|\/+$/, '')
  end

  def strip_html_from_path(path)
    return path&.gsub('.html', '')
  end

  # Will only delete the locale path if it's either:
  # - the first (nz/something) index
  # - or second (/nz/something) index
  def strip_locale_from_path(path)
    split = path&.split('/') || []

    if is_valid_locale_id?(split[0])
      split.delete_at(0)
    elsif split[0]&.empty? && is_valid_locale_id?(split[1])
      split.delete_at(1)
    end

    return wrap_path_in_slashes(split.join('/'))
  end

  def strip_index_from_path(path)
    split = path&.split('/') || []
    split.delete('index') # delete any path called "index"
    return wrap_path_in_slashes(split.join('/'))
  end

  def strip_pagination_from_path(path)
    path = strip_html_from_path(path)
    split = path&.split('/') || []

    # if the path ends in pages/# (# being any regex `\d`), delete both splits
    if split[-2] == 'pages' && split[-1].match(/^\d+$/)
      split.delete_at(-2)
      split.delete_at(-1)
    end

    return  wrap_path_in_slashes(split.join('/'))
  end

  # An absolute url for the image (eg. for Facebook/Twitter)
  def image_url(source)
    return base_url(image_path(source))
  end
end
