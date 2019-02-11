require 'spec_helper'

describe 'Locale Pages', :type => :feature do

  Capybara.app.data.locales.each do |locale|
    it "should load for locale #{locale['id']}" do
      locale.pages.each do |page_data|
        visit localize_path(page_data[:page], locale_id: locale[:id])

        expect(page).to respond_successfully
        expect_basic_meta(page, page_data)
        expect_canonical_urls(page, page_data, locale)
        expect_taglines(page, page_data, locale)
        expect_footer(page)
      end
    end
  end

  private

  def expect_basic_meta(page, page_data)
    base_page_data = base_locale_page(page_data[:page])
    expect(page).to have_base_metas()
    expect(page).to have_social_metas()
    expect(page).to have_titles(page_data[:page_title], base_page_data[:page_title])
    expect(page).to have_descriptions(page_data[:page_description], base_page_data[:page_description])
  end

  def expect_canonical_urls(page, page_data, locale)
    expect(page).to have_meta('og:url', base_url(page_data[:page]), name_key: 'property')
    expect(page).to have_head('link', args: { rel: 'canonical', href: localize_url(page_data[:page], locale_id: locale[:id])}, debug: :href)

    Capybara.app.page_alternative_locales(page_data[:page]).each do |alternate_locale|
      if alternate_locale[:id] == default_locale_id
        expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(page_data[:page], locale_id: default_locale_id), hreflang: 'x-default' }, debug: :href)
      end
      expect(page).to have_head('link', args: { rel: 'alternate', href: localize_url(page_data[:page], locale_id: alternate_locale[:id]), hreflang: alternate_locale[:lang]&.downcase }, debug: :href)
    end
  end

  def expect_taglines(page, page_data, locale)
    ['tagline', 'footer_tagline'].each do |tag|
      expect(page).to have_text(page_data[tag]), "No #{tag} on #{locale[:id]}/#{page_data[:page]}." if page_data[tag]
    end
  end

  def expect_footer(page)
    expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
  end

end
