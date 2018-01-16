require 'cgi'
require 'spec_helper'

describe 'Partners Partner Pages', :type => :feature do

  it "should load" do
    locales.each do |locale|
      get_partners_partners(locale).each do |partner|
        visit partner[:path]

        expect(page).to respond_successfully
      end
    end
  end

  it "should have expected base metas" do
    locales.each do |locale|
      get_partners_partners(locale).each do |partner|
        visit partner[:path]

        expect(page).to have_base_metas()
        expect(page).to have_social_metas()
        expect(page).to have_titles(partner[:page_title])
        expect(page).to have_descriptions(partner[:short_description])
      end
    end
  end

  it "should have expected urls" do
    locales.each do |locale|
      get_partners_partners(locale).each do |partner|
        visit partner[:path]

        expect(page).to have_meta('og:url', base_url(partner[:path]), name_key: 'property')

        expect(page).to have_head('link', args: { rel: 'canonical', href: absolute_url(partner[:path]) }, debug: :href)
        locales.each do |alternate_locale|
          if alternate_locale[:id] == default_locale_id
            expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(partner[:path], locale_id: default_locale_id), hreflang: 'x-default' }, debug: :href)
          end
          expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(partner[:path], locale_id: alternate_locale[:id]), hreflang: alternate_locale[:lang].downcase }, debug: :href)
        end
      end
    end
  end

  it "should have the expected elements" do
    locales.each do |locale|
      get_partners_partners(locale).each do |partner|
        visit partner[:path]

        expect(page).to have_img(partner[:logo][:url]) if partner[:logo]
        expect(page).to have_css('.partner__title', text: /#{Regexp.escape(partner[:name].strip)}$/) if partner[:name]

        if partner[:featured_link] && partner[:featured_link][:link]
          expect(page).to have_css('.featured_link__description', text: partner[:featured_link][:description]) if partner[:featured_link][:description]
          expect(page).to have_css('a.featured_link__button', text: partner[:featured_link][:button_text]) if partner[:featured_link][:button_text]
        end

        # Fairly dumb checks for content.
        expect(page).to have_css('.partner__details dd', text: /#{Regexp.escape(partner[:address].strip)}/) if partner[:address]
        expect(page).to have_css('.partner__details dd', text: /#{Regexp.escape(partner[:city].strip)}/) if partner[:address] && partner[:city]
        expect(page).to have_css('.partner__details dd', text: /#{Regexp.escape(partner[:state].strip)}/) if partner[:address] && partner[:state]
        expect(page).to have_css('.partner__details dd', text: /#{Regexp.escape(partner[:email].strip)}/) if partner[:email]
        expect(page).to have_css('.partner__details dd', text: /#{Regexp.escape(partner[:phone_number].strip)}/) if partner[:phone_number]

        # Dumb checks for just titles.
        expect(page).to have_css('.partner__details dt', text: 'Website') if partner[:website]
        expect(page).to have_css('.partner__details dt', text: 'Category') if partner[:categories].length == 1
        expect(page).to have_css('.partner__details dt', text: 'Categories') if partner[:categories].length > 1

        # Have a footer.
        expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
      end
    end
  end
end
