require 'spec_helper'

describe 'Sitemap', :type => :feature do
  before :each do
    visit '/robots.txt'
  end

  it "should have a sitemap index" do
    expect(page).to have_text('User-agent: *')
    expect(page).to have_text('Disallow: /survey-thanks')
    expect(page).to have_text('Disallow: /404')
    expect(page).to have_text(base_url('/sitemapindex.xml'))

    locales.each do |locale|
      expect(page).to have_text(localize_url('/sitemap.xml', locale_id: locale[:id]))
    end
  end
end
