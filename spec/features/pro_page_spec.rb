require 'spec_helper'

describe 'Pro Page', :type => :feature do
  Capybara.app.data.locales.each do |locale|
    it "should have a main title for locale #{locale['id']}" do
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_css('h1.hero_title', text: 'Sharesight Pro')
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have a get started button for locale #{locale['id']}" do
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_css('.masthead_content a.btn', text: 'BECOME A PRO PARTNER')
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have header text for locale #{locale['id']}" do
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_text("A comprehensive investment portfolio tracker and reporting tool for financial professionals.")
    end
  end
end
