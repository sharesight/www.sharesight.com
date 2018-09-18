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
          expect(page).to have_text(section[:title]) if section[:title] && !section[:title].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then
          expect(page).to have_text(section[:text]) if section[:text] && !section[:text].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then

          section[:contents]&.each do |content|
            expect(page).to have_text(content[:title]) if content[:title] && !content[:title].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then
            expect(page).to have_text(content[:text]) if content[:text] && !content[:text].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then

            content[:buttons]&.each do |button|
              expect(page).to have_text(button[:text]) if button[:text] && !button[:text].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then
            end
          end

          section[:buttons]&.each do |button|
            expect(page).to have_text(button[:text]) if button[:text] && !button[:text].match(/[\*\_\~\-\#]+/) # this could be markdown, we don't test it then
          end
        end

        # Have a footer.
        expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
      end
    end
  end
end
