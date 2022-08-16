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
  end

  context "full_page_path_name" do
    it "should be a string" do
      expect(@app.full_page_path_name).to be_kind_of(::String)
    end

    it "should match expectations for valid pages" do
      [
        # [input, expectation]
        ['/ca/xero', 'xero'],
        ['/xero', 'xero'],
        ['/ca/pro', 'pro'],
        ['/pro', 'pro'],
      ].each do |array|
        visit array[0]
        expect(@app.full_page_path_name).to eq(array[1])
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
      visit '/ca/pro'
      expect(@app.page_path_name).to eq('pro')

      visit '/pro'
      expect(@app.page_path_name).to eq('pro')
    end
  end

  context "base_locale_page" do
    it "should be the page of the global locale" do
      expect(@app.base_locale_page(page: 'xero')[:page_title]).to eq("Xero + Sharesight Portfolio Tracker")

      visit '/pro'
      expect(@app.base_locale_page[:page_title]).to eq("Sharesight Pro")
    end

    it "should return the page from the global locale, even when it doesn't exist on any other locale" do
      expect(@app.base_locale_page(page: 'survey-thanks')[:page_title]).to eq("Thanks | Sharesight")
    end
  end

  context "locale_page" do
    it "should respond with the right page id" do
      expect(@app.locale_page(page: 'pro')[:page]).to eq('pro')
    end

    it "should respond with a localized 'code' based page" do
      expect(@app.locale_page(page: 'pro')[:page_title]).to eq('Sharesight Pro')
      expect(@app.locale_page(page: 'pro', locale_obj: @app.get_locale_obj('global'))[:page_title]).to eq('Sharesight Pro')
      expect(@app.locale_page(page: 'pro', locale_obj: @app.get_locale_obj('au'))[:page_title]).to eq('Sharesight Pro Australia')
      expect(@app.locale_page(page: 'pro', locale_obj: @app.get_locale_obj('ca'))[:page_title]).to eq('Sharesight Pro Canada')
      expect(@app.locale_page(page: 'pro', locale_obj: @app.get_locale_obj('nz'))[:page_title]).to eq('Sharesight Pro New Zealand')
      expect(@app.locale_page(page: 'pro', locale_obj: @app.get_locale_obj('uk'))[:page_title]).to eq('Sharesight Pro UK')
    end

    it "should return a page from the global locale when it doesn't exist on the requested locale" do
      expect(@app.locale_page(page: 'survey-thanks')[:page_title]).to eq("Thanks | Sharesight")

      # This page is special in that it doesn't have a localized version…
      expect(@app.locale_page(page: 'survey-thanks', locale_obj: @app.get_locale_obj('nz'))[:page_title]).to eq("Thanks | Sharesight")
      expect(@app.locale_page(page: 'survey-thanks', locale_obj: @app.get_locale_obj('uk'))[:page_title]).to eq("Thanks | Sharesight")
    end

    it "should respond with nil when no page is found" do
      expect(@app.locale_page(page: 'unknown-page')).to eq(nil)
    end
  end

  context "page_counts" do
    it "should be a hash" do
      expect(@app.page_counts).to be_kind_of(::Hash)
    end

    it "should match expected counts" do
      expect(@app.page_counts['survey-thanks']).to eq(1)

      expect(@app.page_counts['xero']).to eq(6)

      expect(@app.page_counts['fake-page']).to eq(nil)
    end
  end

  context "page_alternative_locales" do
    it "should match expected counts" do
      expect(@app.page_alternative_locales('survey-thanks').length).to eq(1)

      expect(@app.page_alternative_locales('xero').length).to eq(6)

      expect(@app.page_alternative_locales('fake-page')).to be false
    end
  end

  context "is_valid_page?" do
    it "should match expectations" do
      expect(@app.is_valid_page?('xero')).to be true

      expect(@app.is_valid_page?(nil)).to be false
      expect(@app.is_valid_page?('fake-page')).to be false
    end
  end

  context "is_valid_locale_id_for_page?" do
    it "should match expectations" do
      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('xero', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('pro', locale[:id])).to be true
      end

      locales.each do |locale|
        expect(@app.is_valid_locale_id_for_page?('survey-thanks', locale[:id])).to be !!(locale[:id] == 'global')
      end

      expect(@app.is_valid_locale_id_for_page?('xero', nil)).to be false
    end
  end

  context "get_page_base_locale" do
    it "should match expectations" do
      expect(@app.get_page_base_locale('xero')[:id]).to eq(default_locale_id)

      # Bad pages always get default
      expect(@app.get_page_base_locale(nil)[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('foo')[:id]).to eq(default_locale_id)
    end
  end

  context "is_unlocalized_page" do
    it "should return false for xero" do
      expect(@app.is_unlocalized_page?('xero')).to be false
    end

    it "should return false for pro" do
      expect(@app.is_unlocalized_page?('pro')).to be false
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

        ['Foo Bar | Sharesight Canada FooBar', 'Foo Bar | Sharesight FooBar'],
        ['Foo Bar | Sharesight Canadian FooBar', 'Foo Bar | Sharesight Canadian FooBar']
      ].each do |array|
        expect(Capybara.app.generate_social_title(array[0])).to eq(array[1])
      end
    end
  end
end
