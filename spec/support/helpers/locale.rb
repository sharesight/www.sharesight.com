module CapybaraLocaleHelpers
  def locales
    Capybara.app.data.locales
  end

  def default_locale_id
    Capybara.app.default_locale_id
  end

  def default_locale_obj
    Capybara.app.default_locale_obj
  end
end
