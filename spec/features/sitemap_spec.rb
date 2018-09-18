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

  it "should look like a sitemap" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])
      expect(page).to have_xpath('//urlset')

      # we check these numbers to be exact matches below as well
      expect(all(:xpath, '//urlset/url').length).to be > 0
      expect(all(:xpath, '//urlset/url/loc').length).to be > 0
      expect(all(:xpath, '//urlset/url/priority').length).to be > 0
      expect(all(:xpath, '//urlset/url/link').length).to be > 0
    end
  end

  it "should have the right length of links" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      expectation = 0
      expectation += locale[:pages].reject{ |page| page.show_in_sitemap == false }.length

      expectation += get_blog_posts().length if locale[:id] == default_locale_id
      expectation += get_blog_categories().length if locale[:id] == default_locale_id

      expectation += get_partners_partners(locale).length
      expectation += get_partners_categories(all: true).length

      expect(all(:xpath, '//urlset/url').length).to eq(expectation)
      expect(all(:xpath, '//urlset/url/loc').length).to eq(expectation)
    end
  end

  it "should have all the blog posts on the global sitemap" do
    visit @path

    get_blog_posts().each do |post|
      url = Capybara.app.post_url(post)

      xpath = generate_xpath('//urlset/url/loc', text: url)
      expect(page).to have_xpath(xpath), "#{post.title} is missing in sitemap (expected #{url})."
    end
  end

  it "should have all the blog categories on the global sitemap" do
    visit @path

    get_blog_categories().each do |category|
      url = base_url("/blog/#{BasicHelper::url_friendly_string(category.name)}")

      xpath = generate_xpath('//urlset/url/loc', text: url)
      expect(page).to have_xpath(xpath), "#{category.name} is missing in sitemap (expected #{url})."
    end
  end

  it "should have all the partners" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      get_partners_partners().each do |partner|
        url = Capybara.app.partner_url(partner, locale_id: locale[:id])

        xpath = generate_xpath('//urlset/url/loc', text: url)
        expect(page).to have_xpath(xpath), "#{partner.name} is missing in sitemap (expected #{url})."

        locales.each do |sublocale|
          url = Capybara.app.partner_url(partner, locale_id: sublocale.id)
          xpath = generate_xpath('//urlset/url/link', args: { href: url })
          expect(page).to have_xpath(xpath), "#{partner.name} is missing in sitemap (expected #{url})."
        end
      end
    end
  end

  it "should have all the partner categories" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      get_partners_categories(all: true).each do |category|
        url = localize_url("/partners/#{category[:url_slug]}", locale_id: locale[:id])

        xpath = generate_xpath('//urlset/url/loc', text: url)
        expect(page).to have_xpath(xpath), "#{category.name} is missing in sitemap (expected #{url})."

        locales.each do |sublocale|
          url = localize_url("/partners/#{category[:url_slug]}", locale_id: sublocale.id)
          xpath = generate_xpath('//urlset/url/link', args: { href: url })
          expect(page).to have_xpath(xpath), "#{category.name} is missing in sitemap (expected #{url})."
        end
      end
    end
  end

  it "should have all landing pages" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      get_landing_pages(locale).each do |landing_page|
        url = localize_url(landing_page[:url_slug], locale_id: locale[:id])

        xpath = generate_xpath('//urlset/url/loc', text: url)
        expect(page).to have_xpath(xpath), "#{landing_page.url_slug} is missing in sitemap (expected #{url})."

        locales.each do |sublocale|
          url = localize_url(landing_page[:url_slug], locale_id: sublocale.id)
          xpath = generate_xpath('//urlset/url/link', args: { href: url })
          expect(page).to have_xpath(xpath), "#{landing_page.name} is missing in sitemap (expected #{url})."
        end
      end
    end
  end

  it "should have all the pages" do
    locales.each do |locale|
      visit localize_path('sitemap.xml', locale_id: locale[:id])

      locale.pages.each do |page_data|
        url = localize_url("/#{page_data.page}", locale_id: locale.id)
        xpath = generate_xpath('//urlset/url/loc', text: url)

        unless page_data.show_in_sitemap == false
          expect(page).to have_xpath(xpath)
        end
      end
    end
  end

  it "should have all valid links and locs" do
    locales.each do |locale|
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
