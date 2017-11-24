require 'spec_helper'

describe 'Partner Category Pages', :type => :feature do
  before :all do
    @per_page = 30
  end

  it "should load" do
    locales.each do |locale|
      get_partners_categories(locale, all: true).each do |category|
        visit category[:path]

        expect(page).to respond_successfully
      end
    end
  end

  it "should have expected meta tags" do
    locales.each do |locale|
      get_partners_categories(locale, all: true).each do |category|
        visit category[:path]

        expect(page).to have_base_metas()
        expect(page).to have_social_metas()
        expect(page).to have_titles(category[:page_title], category[:social_title])
        expect(page).to have_descriptions(category[:description], category[:social_description])
      end
    end
  end

  it "should have expected urls" do
    locales.each do |locale|
      get_partners_categories(locale, all: true).each do |category|
        subset = 0
        while (category[:partners].length - subset > 0) do
          subset += @per_page
          page_num = subset/@per_page
          page_path = category[:path]
          page_path += "pages/#{page_num}" if page_num > 1
          page_path = page_path

          visit page_path

          expect(page).to respond_successfully

          expect(page).to have_head('link', args: { rel: 'canonical', href: localize_url(page_path, locale_id: locale[:id]) }, debug: :href)
          expect(page).to have_meta('og:url', base_url(category[:path]), name_key: 'property') # no /pages/2...stuff
          locales.each do |alternate_locale|
            if alternate_locale[:id] == default_locale_id
              expect(page).to have_head('link', args: { rel: 'alternate', href: base_url(page_path), hreflang: 'x-default' }, debug: :href)
            end
            expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(page_path, locale_id: alternate_locale[:id]), hreflang: alternate_locale[:lang].downcase }, debug: :href)
          end

          prev = nil # reset on each loop
          prev = "#{category[:path]}/pages/#{page_num - 1}/" if page_num >= 3
          prev = category[:path] if page_num == 2
          expect(page).to have_head('link', args: { rel: 'prev', href: localize_url(prev, locale_id: locale[:id]) }, debug: :href) if prev
          expect(page).to have_head('link', args: { rel: 'next', href: localize_url("#{category[:path]}/pages/#{page_num + 1}/", locale_id: locale[:id]) }, debug: :href) if category[:partners].length - subset > 0
        end
      end
    end
  end

  it "should have the expected elements" do
    locales.each do |locale|
      get_partners_categories(locale, all: true).each do |category|
        visit category[:path]

        expect(page).to have_css('a.breadcrumb', text: 'Partners')

        expect(page).to have_css('h1.partners-header__title', text: category[:title])

        # Expect this to have partners.
        expect(page).to have_selector(:css, 'a.btn', text: 'Learn More', count: category[:partners].length > @per_page ? @per_page : category[:partners].length)

        expect(page).to have_css('.partner-card__category', text: category[:title].singularize()) if category[:id] != 'all'

        # Check for the navigation on the right.
        expect(page).to have_css('.partners-header__categories', text: 'Jump To')
        get_partners_categories(locale, all: true).each do |cat|
          expect(page).to have_css(
            ".partners-header__categories-list li a.partners-header__category[href='#{cat[:url]}']",
            text: cat[:id] == 'all' ? cat[:name] : cat[:title]
          )
        end

        # Check for the next page.
        expect(page).to have_css("a[href='#{localize_url("#{category[:path]}/pages/2/", locale_id: locale[:id])}']", text: 'Next Page') if category[:partners].length > @per_page

        # Have a footer.
        expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
      end
    end
  end
end
