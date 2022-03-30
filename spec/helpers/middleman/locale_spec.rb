require 'spec_helper'

describe 'Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  before :each do
    visit '/partners'
  end

  context "default_locale_id" do
    it "should match global" do
      expect(@app.default_locale_id).to eq('global')
    end
  end

  context "default_locale_obj" do
    it "should have an id of global" do
      expect(@app.default_locale_obj[:id]).to eq('global')
    end
  end

  context "current_locale (id and obj)" do
    it "should have an id matching the path" do
      locales.each do |locale|
        visit locale[:path]
        expect(@app.current_locale_id).to eq(locale[:id])
        expect(@app.current_locale_obj[:id]).to eq(locale[:id])
      end
    end
  end

  context "is_current_locale_id?" do
    it "should be the current locale at the path" do
      locales.each_with_index do |locale, index|
        other_locale = locales[index + (index + 1 < locales.length ? 1 : -1)]
        visit locale[:path]
        expect(@app.is_current_locale_id?(locale[:id])).to be true
        expect(@app.is_current_locale_id?(other_locale[:id])).to be false
      end
    end
  end

  context "get_locale_obj" do
    it "should have an id matching the locale" do
      locales.each do |locale|
        expect(@app.get_locale_obj(locale[:id])[:id]).to eq(locale[:id])

        visit locale[:path]
        expect(@app.get_locale_obj[:id]).to eq(locale[:id])
      end
    end
  end

  context "is_valid_locale_id?" do
    it "should give the correct response" do
      locales.each do |locale|
        expect(@app.is_valid_locale_id?(locale[:id])).to be true
      end

      expect(@app.is_valid_locale_id?(nil)).to be false
      expect(@app.is_valid_locale_id?('')).to be false
      expect(@app.is_valid_locale_id?('gb')).to be false
      expect(@app.is_valid_locale_id?('ug')).to be false
      expect(@app.is_valid_locale_id?('foo')).to be false
    end
  end

  context "is_valid_locale_id_for_base_url?" do
    # This might be only temporary until we add US support to help.sharesight.com
    it "should not allow 'us' locale to help.sharesight.com" do
      expect(@app.is_valid_locale_id_for_base_url?(nil, 'https://help.sharesight.com/')).to be(true)

      all_but_us_locales = locales.reject { |l| l[:id] == 'us' }
      all_but_us_locales.each do |locale|
        expect(@app.is_valid_locale_id_for_base_url?(locale[:id], 'https://help.sharesight.com/')).to be(true), "Didn't do for #{locale[:id]}"
      end

      expect(@app.is_valid_locale_id_for_base_url?('us', 'https://help.sharesight.com/')).to be(false)
    end
  end

  context "locale_cert_type" do
    it "should give the correct response" do
      visit '/partners'
      expect(@app.locale_cert_type).to eq('stock')

      visit '/au'
      expect(@app.locale_cert_type).to eq('share')

      locales.each do |locale|
        visit locale.path
        expect(@app.locale_cert_type).to eq(locale[:cert_type]), "Wrong locale_cert_type at #{locale[:path]}; expected #{locale[:cert_type]}, got #{@app.locale_cert_type}"
      end
    end
  end
end
