# frozen_string_literal: true

module CapybaraUrlHelpers
  def absolute_url(append = '/', base_url: Capybara.app.config[:base_url])
    Capybara.app.absolute_url(append, base_url: base_url)
  end

  # These are mostly just pulled directly in from helpers
  def unlocalized_url(append = '/', base_url: Capybara.app.config[:base_url])
    Capybara.app.unlocalized_url(append, base_url: base_url)
  end

  def localize_url(append = '/', locale_id:, base_url: Capybara.app.config[:base_url])
    Capybara.app.localize_url(append, locale_id: locale_id, base_url: base_url)
  end

  def localize_path(append = '/', locale_id:)
    Capybara.app.localize_path(append, locale_id: locale_id)
  end

  def base_url(append = '/', base_url: Capybara.app.config[:base_url])
    Capybara.app.base_url(append, base_url: base_url)
  end

  # This is entirely custom here
  def base_path(append = '/')
    Capybara.app.base_path(append)
  end
end
