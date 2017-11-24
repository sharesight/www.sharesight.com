require 'spec_helper'

describe 'Locale Pages', :type => :feature do
  it "should load" do
    locales.each do |locale|
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])

        expect(page).to respond_successfully
      end
    end
  end

  it "should have expected meta tags" do
    locales.each do |locale|
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])
        base_page_data = base_locale_page(page_data[:page])

        expect(page).to have_base_metas()
        expect(page).to have_social_metas()
        expect(page).to have_titles(page_data[:page_title], base_page_data[:page_title])
        expect(page).to have_descriptions(page_data[:page_description], base_page_data[:page_description])
      end
    end
  end

  it "should have expected canonical urls" do
    locales.each do |locale|
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])

        expect(page).to have_meta('og:url', base_url(page_data[:page]), name_key: 'property')

        expect(page).to have_head('link', args: { rel: 'canonical', href: localize_url(page_data[:page], locale_id: locale[:id])}, debug: :href)
        Capybara.app.page_alternative_locales(page_data[:page]).each do |alternate_locale|
          if alternate_locale[:id] == default_locale_id
            expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(page_data[:page], locale_id: default_locale_id), hreflang: 'x-default' }, debug: :href)
          end
          expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(page_data[:page], locale_id: alternate_locale[:id]), hreflang: alternate_locale[:lang]&.downcase }, debug: :href)
        end
      end
    end
  end

  it "should have taglines where applicable" do
    locales.each do |locale|
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])

        ['tagline', 'footer_tagline'].each do |tag|
          expect(page).to have_text(page_data[tag]), "No #{tag} on #{locale[:id]}/#{page_data[:page]}." if page_data[tag]
        end
      end
    end
  end

  it "should have a footer" do
    locales.each do |locale|
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])

        expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
      end
    end
  end
end
