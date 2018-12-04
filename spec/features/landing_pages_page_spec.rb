require 'cgi'
require 'spec_helper'

describe 'Landing Pages Pages', :type => :feature do
  it "should load" do
    locales.each do |locale|
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to respond_successfully
      end
    end
  end

  it "should have expected base metas" do
    locales.each do |locale|
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_base_metas()
        expect(page).to have_social_metas()
        expect(page).to have_titles(landing_page[:page_title])
        expect(page).to have_descriptions(landing_page[:meta_description])
      end
    end
  end

  it "should have expected facebook metas" do
    locales.each do |locale|
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_meta('og:type', 'website', name_key: 'property')
      end
    end
  end

  it "should have expected urls" do
    locales.each do |locale|
      get_landing_pages(locale).each do |landing_page|
        visit landing_page[:path]

        expect(page).to have_head('link', args: { rel: 'canonical', href: landing_page[:url] }, debug: :href)
        expect(page).to have_meta('og:url', base_url(landing_page[:path]), name_key: 'property')

        expect(page).to have_head('link', args: { rel: 'alternate', href: base_url('blog/feed.xml') }, debug: :href)
      end
    end
  end

  it "should have the expected elements" do
    locales.each do |locale|
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

  def normalised(string)
    return unless string

    string = string.gsub(/'/, '’')
    string = string.gsub(/\.\.\./, '…')
    string
  end

  def testable?(string)
    return false unless string

    # this could be markdown, we don't test it then
    return false if string.match(/[\*\_\~\-\#]+/)

    true
  end

end
