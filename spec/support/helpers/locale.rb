module CapybaraLocaleHelpers
  def locales
    return Capybara.app.data.locales
  end

  def default_locale_id
    return Capybara.app.default_locale_id
  end

  def default_locale_obj
    return Capybara.app.default_locale_obj
  end
end
