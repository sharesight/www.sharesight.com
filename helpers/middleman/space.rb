load File::expand_path('./page.rb', __dir__)

module MiddlemanSpaceHelpers
  include MiddlemanPageHelpers # for locale_page method

  def is_category_page?
    category = current_page.metadata[:locals][:category]
    return true if category && category[:id] && category[:id].downcase != 'all'

    false
  end

  def space_category_title
    # NOTE: the blog has been removed, though this check is there to ensure it's the partners page
    space = if current_path_array.any?{ |path| /^partners/ =~ path }
      'Partners'
    end
    # The locals.category is passed here by pagination proxy via the locals hash.
    category = current_page.metadata[:locals][:category]
    return space unless is_category_page?
    return "#{category[:name]} Partners" if space&.downcase == 'partners'
    category[:name]
  end

  def space_category_page_title
    return locale_page[:page_title] unless is_category_page?

    "#{space_category_title} | #{current_locale_obj[:append_title]}"
  end

  def base_space_category_page_title
    return base_locale_page[:page_title] || locale_page[:page_title] unless is_category_page?

    "#{space_category_title} | #{default_locale_obj[:append_title]}"
  end
end
