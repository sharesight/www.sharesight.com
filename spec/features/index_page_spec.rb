require 'spec_helper'

describe 'Index Page', :type => :feature do
  it "should have a hero title" do
    visit '/'
    expect(page).to have_css('h1', text: 'Become a better investor')
  end

  it "should have a get started button in the hero" do
    visit '/'
    expect(page).to have_css('.index-hero a.btn', text: 'GET STARTED – FOR FREE')
  end

  Capybara.app.data.locales.each do |locale|
    it "should have localized text for locale #{locale['id']}" do
      visit locale.path
      expect(page).to have_text("Simply the best #{locale.cert_type} portfolio tracker for #{locale.for_country} investors".squeeze(' '))
    end
  end
end
