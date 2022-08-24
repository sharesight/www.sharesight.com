require 'spec_helper'

describe 'Sitemap', :type => :feature do
  before :all do
    @path = 'sitemap.xml'
    @validated = []
  end

  it "should have a sitemap index" do
    visit '/sitemapindex.xml'
    expect(page).to have_xpath('//sitemapindex')

    # we check these numbers to be exact matches below as well
    expect(all(:xpath, '//sitemapindex/sitemap').length).to eq(locales.length)
    expect(all(:xpath, '//sitemapindex/sitemap/loc').length).to eq(locales.length)
  end

  Capybara.app.data.locales.each do |locale|
    it "should look like a sitemap for locale #{locale['id']}" do
      visit localize_path('sitemap.xml', locale_id: locale[:id])
      expect(page).to have_xpath('//urlset')

      # we check these numbers to be exact matches below as well
      expect(all(:xpath, '//urlset/url').length).to be > 0
      expect(all(:xpath, '//urlset/url/loc').length).to be > 0
      expect(all(:xpath, '//urlset/url/priority').length).to be > 0
      expect(all(:xpath, '//urlset/url/link').length).to be > 0
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have the right length of links for locale #{locale['id']}" do
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      expectation = 0
      expectation += locale[:pages].reject{ |page| page[:no_index] == true }.length

      expect(all(:xpath, '//urlset/url').length).to eq(expectation)
      expect(all(:xpath, '//urlset/url/loc').length).to eq(expectation)
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have all the pages for locale #{locale['id']}" do
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      locale.pages.each do |page_data|
        url = localize_url("/#{page_data.page}", locale_id: locale.id)
        xpath = generate_xpath('//urlset/url/loc', text: url)

        if page_data[:no_index] == true
          expect(page).not_to have_xpath(xpath)
        else
          expect(page).to have_xpath(xpath)
        end
      end
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have all valid links and locs for locale #{locale['id']}" do
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      links = []
      links << all('//urlset/url/loc').map{ |xpath| xpath.text() }
      links << all('//urlset/url/link').map{ |xpath| xpath['href'] }
      links = links.flatten.uniq

      links.each do |link|
        # don't re-visit every url
        if !@validated.include?(link)
          visit link
          @validated << link
          expect(page).to respond_successfully
        end
      end
    end
  end
end
