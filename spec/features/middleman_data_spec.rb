require 'spec_helper'

# This tests that the auto-generated portion of the spec matches what we expect it to!

describe 'Middleman Data', :type => :feature do
  it "should have expected data set for locales" do
    expect(locales.length).to eq(5)

    locales.each do |locale|
      # converts to hash before getting keys!
      expect(locale.to_h.keys).to include(
        'id', 'path', 'name', 'lang', 'currency', 'currency_symbol', 'plans_include_tax',
        'cert_type', 'country', 'for_country', 'default_title', 'append_title',
        'footer_ios_alt', 'footer_android_alt', 'pages'
      ), "Locale #{locale.id} does not have all the correct keys."
    end
  end

  it "should have expected locales" do
    expect(locales.map{|x| x.id}).to include('global', 'au', 'ca', 'nz', 'uk')
  end

  it "should have expected locale paths" do
    expect(locales.map{|x| x.path}).to include('/', '/au/', '/ca/', '/nz/', '/uk/')
  end

  it "should have expected languages" do
    expect(locales.map{|x| x.lang}).to include('en', 'en-AU', 'en-CA', 'en-NZ', 'en-GB')
  end
end
