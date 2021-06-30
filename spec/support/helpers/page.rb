# frozen_string_literal: true

module CapybaraPageHelpers
  def locale_page(page, locale_obj)
    Capybara.app.locale_page(page: page, locale_obj: locale_obj)
  end

  def base_locale_page(page)
    Capybara.app.base_locale_page(page: page)
  end
end
