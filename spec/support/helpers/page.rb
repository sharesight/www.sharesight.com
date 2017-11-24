module CapybaraPageHelpers
  def locale_page(page, locale_obj)
    return Capybara.app.locale_page(page: page, locale_obj: locale_obj)
  end

  def base_locale_page(page)
    return Capybara.app.base_locale_page(page: page)
  end
end
