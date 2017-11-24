require 'spec_helper'

describe 'Page Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  before :each do
    visit '/'
  end

  context "current_path_array" do
    it "should be an array" do
      expect(@app.current_path_array).to be_kind_of(::Array)

      visit '/nz'
      expect(@app.current_path_array).to be_kind_of(::Array)
    end

    it "should include what we expect" do
      expect(@app.current_path_array).to include('index.html')

      visit '/nz/partners/foo-bar'
      expect(@app.current_path_array).to eq(['index.html']) # invalid page, falls back to previous path

      visit '/nz/partners/all'
      expect(@app.current_path_array).to include('partners', 'all.html')
    end
  end

  context "full_page_path_name" do
    it "should be a string" do
      expect(@app.full_page_path_name).to be_kind_of(::String)
    end

    it "should match expectations for valid pages" do
      [
        # [input, expectation]
        ['/', 'index'],
        ['/nz', 'index'],
        ['/ca/faq', 'faq'],
        ['/faq', 'faq'],
        ['/nz/partners', 'partners'],
        ['/partners/all', 'partners/all'],
        ['/blog', 'blog'],
      ].each do |array|
        visit array[0]
        expect(@app.full_page_path_name).to eq(array[1])
      end
    end

    it "should match expectations for invalid pages" do
      # NOTE: Invalid pages do not get a new current_page global, so we must mock it

      [
        # [input, expectation]
        ['/partners/all/pages/2', 'partners/all'],
        ['/partners/all/pages/a', 'partners/all/pages/a'],
        ['/partners/all/pages', 'partners/all/pages'],
        ['/partners/all/some-pages/2', 'partners/all/some-pages/2'],
        ['/partners/all/page/2', 'partners/all/page/2'],
        ['/blog/some-blog-post', 'blog/some-blog-post'],
        ['/blog/category/pages/2.html', 'blog/category']
      ].each do |array|
        visit array[0]
        expect(@app.full_page_path_name(path: array[0])).to eq(array[1])
      end
    end
  end

  context "page_path_name" do
    it "should be a string" do
      expect(@app.page_path_name).to be_kind_of(::String)

      visit '/nz'
      expect(@app.page_path_name).to be_kind_of(::String)
    end

    it "should match what we expect" do
      expect(@app.page_path_name).to eq('index')

      visit '/nz'
      expect(@app.page_path_name).to eq('index')

      visit '/ca/faq'
      expect(@app.page_path_name).to eq('faq')

      visit '/faq'
      expect(@app.page_path_name).to eq('faq')

      visit '/nz/partners'
      expect(@app.page_path_name).to eq('partners')

      visit '/partners'
      expect(@app.page_path_name).to eq('partners')

      visit '/blog'
      expect(@app.page_path_name).to eq('blog')
    end
  end

  context "current_locale_page" do
    # This is a 1:1 proxy of locale_page
    it "should be the page we expect" do
      expect(@app.current_locale_page[:page]).to eq('index')

      visit '/blog'
      expect(@app.current_locale_page[:page]).to eq('blog')

      visit '/nz/partners'
      expect(@app.current_locale_page[:page]).to eq('partners')
    end
  end

  context "valid_page_from_path" do
    # This is a 1:1 proxy of locale_page
    it "should be the page we expect" do
      [
        # [input, expectation]
        ['/', 'index'],
        ['/blog', 'blog'],
        ['/nz/partners', 'partners'],
        ['/ca/partners/all', 'partners/all'],
        ['/partners/all', 'partners/all']
      ].each do |array|
        visit array[0]
        expect(@app.valid_page_from_path).to eq(array[1])
      end
    end

    it "should be the parent page for a partner entry" do
      first_partner = get_partners_partners().find{ |model| model[:name] }

      visit @app.partner_path(first_partner)
      expect(@app.base_locale_page[:page]).to eq("partners")
    end
  end

  context "base_locale_page" do
    it "should be the page of the global locale" do
      expect(@app.base_locale_page(page: 'index')[:page_title]).to eq("Stock Portfolio Tracker | Sharesight")
      expect(@app.base_locale_page(page: 'xero')[:page_title]).to eq("Xero + Sharesight Portfolio Tracker")

      visit '/pro'
      expect(@app.base_locale_page[:page_title]).to eq("Sharesight Pro")
    end

    it "should be a valid on the partners base" do
      visit 'nz/partners'
      expect(@app.base_locale_page[:page]).to eq("partners")
    end

    it "should be a valid on the partners/all path" do
      visit 'nz/partners/all'
      expect(@app.base_locale_page[:page]).to eq("partners/all")
    end

    it "should be partners for the first partner" do
      first_partner = get_partners_partners().find{ |model| model[:name] }

      visit @app.partner_path(first_partner)
      expect(@app.base_locale_page[:page]).to eq("partners")
    end

    it "should return the page from a locale that isn't global" do
      expect(@app.base_locale_page(page: 'lp-general-ca')[:page_title]).to eq("Investment Tracking Software | Sharesight Canada")
    end

    it "should return the page from the global locale, even when it doesn't exist on any other locale" do
      expect(@app.base_locale_page(page: 'survey-thanks')[:page_title]).to eq("Thanks | Sharesight")
    end
  end

  context "locale_page" do
    it "should respond with the right page id" do
      expect(@app.locale_page(page: 'index')[:page]).to eq('index')
      expect(@app.locale_page(page: 'blog')[:page]).to eq('blog')
      expect(@app.locale_page(page: 'faq')[:page]).to eq('faq')
      expect(@app.locale_page(page: 'faq', locale_obj: @app.get_locale_obj('nz'))[:page]).to eq('faq')

      expect(@app.locale_page(page: 'fake-page')).to eq(nil)
    end
  end

  context "page_counts" do
    it "should be a hash" do
      expect(@app.page_counts).to be_kind_of(::Hash)
    end

    it "should match expected counts" do
      expect(@app.page_counts['blog']).to eq(1)
      expect(@app.page_counts['lp-general-ca']).to eq(1)
      expect(@app.page_counts['survey-thanks']).to eq(1)

      expect(@app.page_counts['index']).to eq(5)
      expect(@app.page_counts['404']).to eq(5)
      expect(@app.page_counts['xero']).to eq(5)
      expect(@app.page_counts['partners']).to eq(5)

      expect(@app.page_counts['fake-page']).to eq(nil)
    end
  end

  context "page_alternative_locales" do
    it "should be a hash" do
      expect(@app.page_alternative_locales('blog')).to be_kind_of(::Array)
    end

    it "should match expected counts" do
      expect(@app.page_alternative_locales('blog').length).to eq(1)
      expect(@app.page_alternative_locales('lp-general-ca').length).to eq(1)
      expect(@app.page_alternative_locales('survey-thanks').length).to eq(1)

      expect(@app.page_alternative_locales('index').length).to eq(5)
      expect(@app.page_alternative_locales('404').length).to eq(5)
      expect(@app.page_alternative_locales('xero').length).to eq(5)
      expect(@app.page_alternative_locales('partners').length).to eq(5)

      expect(@app.page_alternative_locales('fake-page')).to be false
    end
  end

  context "is_valid_page?" do
    it "should match expectations" do
      expect(@app.is_valid_page?('blog')).to be true
      expect(@app.is_valid_page?('xero')).to be true
      expect(@app.is_valid_page?('404')).to be true
      expect(@app.is_valid_page?('partners')).to be true
      expect(@app.is_valid_page?('lp-general-ca')).to be true

      expect(@app.is_valid_page?(nil)).to be false
      expect(@app.is_valid_page?('fake-page')).to be false
    end
  end

  context "is_valid_locale_id_for_page?" do
    it "should match expectations" do
      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('blog', locale[:id])).to be !!(locale[:id] == 'global')
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('xero', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('partners', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('faq', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('index', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('survey-thanks', locale[:id])).to be !!(locale[:id] == 'global')
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('lp-general-ca', locale[:id])).to be !!(locale[:id] == 'ca')
      end

      expect(@app.is_valid_locale_id_for_page?('index', 'gb')).to be false
      expect(@app.is_valid_locale_id_for_page?('blog', 'uka')).to be false
      expect(@app.is_valid_locale_id_for_page?('xero', nil)).to be false
      expect(@app.is_valid_locale_id_for_page?('partners', 'nzd')).to be false
    end
  end

  context "get_page_base_locale" do
    it "should match expectations" do
      expect(@app.get_page_base_locale('blog')[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('xero')[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('index')[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('partners')[:id]).to eq(default_locale_id)

      # Non-global.
      expect(@app.get_page_base_locale('lp-general-ca')[:id]).to eq('ca')

      # Bad pages always get default
      expect(@app.get_page_base_locale(nil)[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('foo')[:id]).to eq(default_locale_id)
    end
  end

  context "is_unlocalized_page" do
    it "should return true for blog" do
      expect(@app.is_unlocalized_page?('blog')).to be true
    end

    it "should return false for xero" do
      expect(@app.is_unlocalized_page?('xero')).to be false
    end

    it "should return false for index" do
      expect(@app.is_unlocalized_page?('index')).to be false
    end

    it "should return false for faq" do
      expect(@app.is_unlocalized_page?('faq')).to be false
    end

    it "should return false for an unknown page" do
      expect(@app.is_unlocalized_page?('some-fake-page-please-dont-make-this')).to be false
      expect(@app.is_unlocalized_page?(nil)).to be false
    end
  end

  context "generate_social_title" do
    it "should strip the localization of the title" do
      [
        # [input, expectation]
        ['Foo Bar | Sharesight Canada', 'Foo Bar | Sharesight'],
        ['Foo Bar | Sharesight', 'Foo Bar | Sharesight'],
        ['Foo Bar | Sharesight Australia', 'Foo Bar | Sharesight'],
        ['Foo Bar | Sharesight Unknown', 'Foo Bar | Sharesight Unknown'],
        ['Foo Bar | Canada', 'Foo Bar | Canada'],
        ['Foo Bar + Sharesight Australia', 'Foo Bar + Sharesight Australia'],
        ['Foo Bar - Sharesight Australia', 'Foo Bar - Sharesight Australia'],
        ['Foo Bar |Sharesight Australia', 'Foo Bar |Sharesight Australia'],
        [' | Sharesight UK', ' | Sharesight'],
        ['Sharesight UK', 'Sharesight UK'],

        ['Foo Bar | Sharesight Canada Partners', 'Foo Bar | Sharesight Partners'],
        ['Foo Bar | Sharesight Canada FooBar', 'Foo Bar | Sharesight FooBar'],
        ['Foo Bar | Sharesight Canadian FooBar', 'Foo Bar | Sharesight Canadian FooBar']
      ].each do |array|
        expect(Capybara.app.generate_social_title(array[0])).to eq(array[1])
      end
    end
  end
end
