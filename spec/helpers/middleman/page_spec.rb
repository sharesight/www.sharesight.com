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
  end

  context "page_path_name" do
    it "should be a string" do
      expect(@app.page_path_name).to be_kind_of(::String)

      visit '/nz'
      expect(@app.page_path_name).to be_kind_of(::String)
    end
  end

  context "locale_page" do
    it "should respond with nil when no page is found" do
      expect(@app.locale_page(page: 'unknown-page')).to eq(nil)
    end
  end

  context "page_counts" do
    it "should be a hash" do
      expect(@app.page_counts).to be_kind_of(::Hash)
    end

    it "should match expected counts" do
      expect(@app.page_counts['fake-page']).to eq(nil)
    end
  end

  context "page_alternative_locales" do
    it "should match expected counts" do
      expect(@app.page_alternative_locales('fake-page')).to be false
    end
  end

  context "is_valid_page?" do
    it "should match expectations" do
      expect(@app.is_valid_page?(nil)).to be false
      expect(@app.is_valid_page?('fake-page')).to be false
    end
  end

  context "is_valid_locale_id_for_page?" do
    it "should match expectations" do
      locales.each do |locale|
      end

      locales.each do |locale|
    end
  end

  context "get_page_base_locale" do
    it "should match expectations" do
      # Bad pages always get default
      expect(@app.get_page_base_locale(nil)[:id]).to eq(default_locale_id)
      expect(@app.get_page_base_locale('foo')[:id]).to eq(default_locale_id)
    end
  end

  context "is_unlocalized_page" do
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
