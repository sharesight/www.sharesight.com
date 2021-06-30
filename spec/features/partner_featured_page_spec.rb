require 'spec_helper'

describe 'Partner Category Pages', type: :feature do
  before :all do
    @path = 'partners/'
  end

  Capybara.app.data.locales.each do |locale|
    it "should load for locale #{locale['id']}" do
      visit localize_path(@path, locale_id: locale[:id])

      expect(page).to respond_successfully
      expect_basic_tags(page, locale_page('partners', locale))
      expect_urls(page, locale)
      expect_elements(page, locale)
    end
  end

  private

  def expect_basic_tags(page, current_locale_page)
    base_page = base_locale_page('partners')
    expect(page).to have_base_metas
    expect(page).to have_social_metas
    expect(page).to have_titles(current_locale_page[:page_title], base_page[:page_title])
    expect(page).to have_descriptions(current_locale_page[:page_description], base_page[:page_description])
  end

  def expect_urls(page, locale)
    expect(page).to have_meta('og:url', base_url(@path), name_key: 'property')
    expect(page).to have_head('link', args: { rel: 'canonical', href: localize_url(@path, locale_id: locale[:id]) },
                                      debug: :href)
    locales.each do |alternate_locale|
      if alternate_locale[:id] == default_locale_id
        expect(page).to have_head('link',
                                  args: { rel: 'alternate', href: localize_url(@path, locale_id: default_locale_id), hreflang: 'x-default' }, debug: :href)
      end
      expect(page).to have_head('link',
                                args: { rel: 'alternate', href: localize_url(@path, locale_id: alternate_locale[:id]), hreflang: alternate_locale[:lang].downcase }, debug: :href)
    end
  end

  def expect_elements(page, locale)
    categories = get_partners_categories(locale, all: true)

    expect(page).not_to have_css('a.breadcrumb', text: 'Partners')

    expect(page).to have_css('h1.partners-header__title', text: 'Partners')

    # Expect this to have partners.
    expect(page).to have_selector(:css, 'a.btn', text: 'Learn More')

    # Check for the navigation on the right.
    expect(page).to have_css('.partners-header__categories', text: 'Jump To')
    categories.each do |cat|
      expect(page).to have_css(
        ".partners-header__categories-list li a.partners-header__category[href='#{cat[:url]}']",
        text: cat[:id] == 'all' ? cat[:name] : cat[:title]
      )
    end

    categories.each do |cat|
      expect(page).to have_css('.partner-category__title',
                               text: /^#{cat[:id] == 'all' ? 'Featured Partners' : cat[:name]}/)
      expect(page).to have_css(
        ".partner-category__title a.partner-category__browse[href='#{cat[:url]}']",
        text: "Browse #{cat[:id] == 'all' ? 'All' : cat[:name].singularize} Partners →".squeeze(' ')
      )
    end

    # Have a "Become a Partner" button.
    expect(page).to have_css("a[href='#{localize_url('become-a-partner', locale_id: locale[:id])}']",
                             text: 'Become a Partner')

    # Have a footer.
    expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
  end
end
