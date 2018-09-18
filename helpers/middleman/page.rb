load File::expand_path('./locale.rb', __dir__)
load File::expand_path('./url.rb', __dir__)

module MiddlemanPageHelpers
  include MiddlemanLocaleHelpers
  include MiddlemanUrlHelpers

  def current_path_array(path: current_page.path)
    return path.split("/")
  end

  def full_page_path_name(path: current_page.path)
    path = strip_html_from_path(path)
    path = strip_locale_from_path(path)

    # do not remove index from path if it's the only path!
    path = strip_index_from_path(path) if trim_wrapped_slashes(path) != 'index'

    path = strip_pagination_from_path(path)
    path = trim_wrapped_slashes(path)
    path = path&.downcase

    return path || ''
  end

  def page_path_name(path: current_page.path)
    # first valid split
    return full_page_path_name(path: path).split('/').find{ |split| (split || '') != '' }
  end

  def current_locale_page
    return locale_page
  end

  def valid_page_from_path(path: current_page.path)
    full = full_page_path_name(path: path)
    base = page_path_name(path: path)
    return full if is_valid_page?(full)
    return base || nil
  end

  def base_locale_page(page: valid_page_from_path)
    get_page_base_locale(page)&.pages&.find{ |p| p[:page] == page } || locale_page(page: page)
  end

  def locale_page(page: valid_page_from_path, locale_obj: current_locale_obj)
    page = page&.downcase&.sub(/\.html$/, '')

    # Look through the current locale's pages for the page; if not found, look in the default locale's pages; return the output.
    found_page = locale_obj.pages.find{ |y| y[:page] == page }

    if found_page.nil?
      # Not found, find the first one where the page is found.
      # Ie. trying to find a page that only exists in the canadian locale, but we're not in the canadian locale.
      found_page = data.locales.find{ |locale| locale.pages&.find {|y| y[:page] == page } }&.pages&.find {|y| y[:page] == page}
    end

    if found_page.nil?
      found_page = get_landing_page(page)
    end

    return found_page || {} # default to an empty hash
  end

  def page_alternative_locales(page_name = valid_page_from_path)
    return false if !is_valid_page?(page_name)
    return data.locales if get_landing_page(page_name)

    @page_alternative_locales ||= data.locales.reduce({}) do |hash, locale|
      locale.pages.each do |page_data|
        hash[page_data.page] = [] if !hash[page_data.page]
        hash[page_data.page] << locale
      end
      hash # return to reduce
    end

    return @page_alternative_locales[page_name] || []
  end

  def page_counts
    return @page_counts ||= data.locales.reduce({}) do |hash, locale|
      locale.pages.each do |page_data|
        hash[page_data.page] = 0 if !hash[page_data.page]
        hash[page_data.page] += 1
      end
      hash # return to reduce
    end
  end

  def is_valid_page?(page_name)
    return !!locale_page(page: page_name)
  end

  def is_landing_page?(page_name)
    return !!get_landing_page(page_name)
  end

  def is_valid_locale_id_for_page?(page_name, locale_id)
    return false if !is_valid_locale_id?(locale_id)
    return true if is_landing_page?(page_name) # available in all locales
    return false if !is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = page_alternative_locales(page[:page])
    return false if !locales

    return !!locales.find{ |locale| locale[:id] == locale_id }
  end

  # Returns the first locale.  This should be default_locale_obj, by default.
  # NOTE: This makes bad usage of rescue as we expect not found pages and locales to result in the default locale.
  def get_page_base_locale(page_name)
    return default_locale_obj if !is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = page_alternative_locales(page[:page])
    return default_locale_obj if !locales || !locales.length || !locales[0] || !locales[0][:id]

    return locales[0]
  end

  def get_landing_page(page_name = valid_page_from_path)
    found = landing_pages_collection.find{ |page| page.url_slug == page_name }
    return unless found

    found.with_indifferent_access
  end

  # NOTE: This makes bad usage of rescue as we expect not found pages and locales to result in it's localized (default).
  def is_unlocalized_page?(page_name)
    return false if !is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = page_alternative_locales(page[:page]) rescue false
    return locales.length == 1 && locales[0][:id] == default_locale_id rescue false
  end

  def generate_social_title(title)
    return nil if !title
    global = " | #{config[:site_name]}"

    data.locales.each do |locale|
      localized = " | #{locale[:append_title]}"
      if title.include?(localized) && localized != global
        title = title.sub(localized, global)
      end
    end

    return title
  end
end
