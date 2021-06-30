# frozen_string_literal: true

load File.expand_path('./locale.rb', __dir__)
load File.expand_path('./url.rb', __dir__)

module MiddlemanPageHelpers
  include MiddlemanLocaleHelpers
  include MiddlemanUrlHelpers

  def current_path_array(path: current_page.path)
    path.split('/')
  end

  def full_page_path_name(path: current_page.path)
    path = strip_html_from_path(path)
    path = strip_locale_from_path(path)

    # do not remove index from path if it's the only path!
    path = strip_index_from_path(path) if trim_wrapped_slashes(path) != 'index'

    path = strip_pagination_from_path(path)
    path = trim_wrapped_slashes(path)
    path = path&.downcase

    path || ''
  end

  def page_path_name(path: current_page.path)
    # first valid split
    full_page_path_name(path: path).split('/').find { |split| (split || '') != '' }
  end

  def current_locale_page
    locale_page
  end

  def valid_page_from_path(path: current_page.path)
    full = full_page_path_name(path: path)
    base = page_path_name(path: path)
    return full if is_valid_page?(full)

    base || nil
  end

  def base_locale_page(page: valid_page_from_path)
    get_page_base_locale(page)&.pages&.find { |p| p[:page] == page } || locale_page(page: page)
  end

  def locale_page(page: valid_page_from_path, locale_obj: current_locale_obj)
    page = page&.downcase&.sub(/\.html$/, '')

    # Look through the current locale's pages for the page; if not found, look in the default locale's pages; return the output.
    found_page = locale_obj[:pages].find { |y| y[:page] == page }

    if found_page.nil?
      # Not found, find the first one where the page is found.
      # Ie. trying to find a page that only exists in the canadian locale, but we're not in the canadian locale.
      found_page = data.locales.find do |locale|
                     locale.pages&.find do |y|
                       y[:page] == page
                     end
                   end&.pages&.find { |y| y[:page] == page }
    end

    found_page = get_landing_page(page, locale_obj: locale_obj) if found_page.nil?

    found_page # may return a nil here!
  end

  def page_alternative_locales(page_name = valid_page_from_path)
    return false unless is_valid_page?(page_name)
    return data.locales if get_landing_page(page_name, locale_obj: default_locale_obj)

    @page_alternative_locales ||= data.locales.each_with_object({}) do |locale, hash|
      locale.pages.each do |page_data|
        hash[page_data.page] = [] unless hash[page_data.page]
        hash[page_data.page] << locale
      end
      # return to reduce
    end

    @page_alternative_locales[page_name] || false
  end

  def page_counts
    @page_counts ||= data.locales.each_with_object({}) do |locale, hash|
      locale.pages.each do |page_data|
        hash[page_data.page] = 0 unless hash[page_data.page]
        hash[page_data.page] += 1
      end
      # return to reduce
    end
  end

  def is_valid_page?(page_name = valid_page_from_path)
    !!locale_page(page: page_name)
  end

  def is_landing_page?(page_name = valid_page_from_path)
    !!get_landing_page(page_name, locale_obj: default_locale_obj)
  end

  def is_valid_locale_id_for_page?(page_name, locale_id)
    return false unless is_valid_locale_id?(locale_id)
    return true if is_landing_page?(page_name) # available in all locales
    return false unless is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = page_alternative_locales(page[:page])
    return false unless locales

    !!locales.find { |locale| locale[:id] == locale_id }
  end

  # Returns the first locale.  This should be default_locale_obj, by default.
  # NOTE: This makes bad usage of rescue as we expect not found pages and locales to result in the default locale.
  def get_page_base_locale(page_name)
    return default_locale_obj unless is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = page_alternative_locales(page[:page])
    return default_locale_obj if !locales || !locales.length || !locales[0] || !locales[0][:id]

    locales[0]
  end

  def get_landing_page(page_name = valid_page_from_path, locale_obj: current_locale_obj)
    found = landing_pages_collection(locale_obj: locale_obj).find { |page| page.url_slug == page_name }
    return unless found

    found.with_indifferent_access
  end

  # NOTE: This makes bad usage of rescue as we expect not found pages and locales to result in it's localized (default).
  def is_unlocalized_page?(page_name)
    return false unless is_valid_page?(page_name)

    page = locale_page(page: page_name)
    locales = begin
      page_alternative_locales(page[:page])
    rescue StandardError
      false
    end
    begin
      locales.length == 1 && locales[0][:id] == default_locale_id
    rescue StandardError
      false
    end
  end

  def generate_social_title(title)
    return nil unless title

    global = " | #{config[:site_name]}"

    data.locales.each do |locale|
      localized = " | #{locale[:append_title]}"
      title = title.sub(localized, global) if title.include?(localized) && localized != global
    end

    title
  end
end
