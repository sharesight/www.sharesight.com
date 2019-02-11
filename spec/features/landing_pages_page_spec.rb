require 'cgi'
require 'spec_helper'

describe 'Landing Pages Pages', :type => :feature do
  Capybara.app.data.locales.each do |locale|
    it "should load for locale #{locale['id']}" do
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to respond_successfully
      end
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have expected base metas for locale #{locale['id']}" do
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_base_metas()
        expect(page).to have_social_metas()
        expect(page).to have_titles(landing_page[:page_title])
        expect(page).to have_descriptions(landing_page[:meta_description])
      end
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have expected facebook metas for locale #{locale['id']}" do
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_meta('og:type', 'website', name_key: 'property')
      end
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have expected urls for locale #{locale['id']}" do
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_head('link', args: { rel: 'canonical', href: landing_page[:url] }, debug: :href)
        expect(page).to have_meta('og:url', base_url(landing_page[:path]), name_key: 'property')

        expect(page).to have_head('link', args: { rel: 'alternate', href: base_url('blog/feed.xml') }, debug: :href)
      end
    end
  end

  Capybara.app.data.locales.each do |locale|
    it "should have the expected elements for locale #{locale['id']}" do
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        # has a logo
        expect(page).to have_css('nav #site_logo img')

        landing_page[:sections]&.each do |section|
          expect_page_text(section[:title])
          expect_page_text(section[:text])

          section[:contents]&.each do |content|
            expect_page_text(content[:title])
            expect_page_text(content[:text])

            content[:buttons]&.each do |button|
              expect_page_text(button[:text])
            end
          end

          section[:buttons]&.each do |button|
            expect_page_text(button[:text])
          end
        end

        # Have a footer.
        expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
      end
    end
  end

  private

  def expect_page_text(string)
    string = normalised(string)
    expect(page).to have_text(string) if testable?(string)
  end

  # kramdown converts certain ASCII characters into typographic symbols
  # see https://kramdown.gettalong.org/syntax.html#typographic-symbols
  # we have to do the same
  def normalised(string)
    return unless string

    # single quotes
    string = string.gsub(/'/, '’')
    # double quotes
    string = string.gsub(/"/, '“')
    # ellipsis
    string = string.gsub(/\.\.\./, '…')
    # em-dash
    string = string.gsub(/---/, '—')
    # en-dash
    string = string.gsub(/--/, '–')
    # left guillemet
    string = string.gsub(/<</, '«')
    # right guillemet
    string = string.gsub(/>>/, '»')

    string
  end

  def testable?(string)
    return false unless string

    # this could be markdown, we don't test it then
    return false if string.match(/[\*\_\~\-\#]+/)

    true
  end

end
