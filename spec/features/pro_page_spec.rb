require 'spec_helper'

describe 'Pro Page', :type => :feature do
  it "should have a main title" do
    locales.each do |locale|
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_css('h1.hero_title', text: 'Sharesight Pro')
    end
  end

  it "should have a get started button" do
    locales.each do |locale|
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_css('.masthead_content a.btn', text: 'BECOME A PRO PARTNER')
    end
  end

  it "should have header text" do
    locales.each do |locale|
      visit localize_url('pro', locale_id: locale.id)
      expect(page).to have_text("A comprehensive investment portfolio tracker and reporting tool for financial professionals.")
    end
  end
end
