require 'spec_helper'

# This tests that the middleman helpers (not testable directly) work as expected.

# base_output will trump output when we're dealing with localization
expectations = [
  { append: '', locale_id: nil, output: '' },
  { append: '/', locale_id: nil, output: '' },
  { append: 'index.html', locale_id: nil, output: '' },
  { append: '/index.html', locale_id: nil, output: '' },
  { append: '/nz/', locale_id: nil, output: '' }, # supported locale
  { append: '/jp/', locale_id: nil, output: '/jp/' }, # unsupported locale
  { append: '/nz/', locale_id: 'global', output: '' },
  { append: '/jp/', locale_id: 'global', output: '/jp/' },

  { append: '/nz/foo/', locale_id: 'nz', output: '/nz/foo/', base_output: '/foo/' },
  { append: '/jp/index.html', locale_id: 'nz', output: '/nz/jp/', base_output: '/jp/' },
  { append: '/nz/index.html', locale_id: 'au', output: '/au/', base_output: '' }, # switch to locale

  { append: 'blog/sitemap.xml', locale_id: nil, output: '/blog/sitemap.xml' },
  { append: 'foo.bar#baz', locale_id: nil, output: '/foo.bar#baz' },
  { append: 'nz/pricing?foo&bar', locale_id: 'au', output: '/au/pricing?foo&bar', base_output: '/pricing?foo&bar' },
  { append: 'au/pricing?foo&bar#baz', locale_id: 'global', output: '/pricing?foo&bar#baz' }
]

describe 'Base Middleman Helpers', :type => :unit do
  it "localize_url should handle urls as expected" do
    base_urls = [
      Capybara.app.config[:base_url],
      Capybara.app.config[:help_url],
      'https://foo.bar/'
    ]

    base_urls.each do |base|
      expectations.each do |hash|
        expect(Capybara.app.localize_url(hash[:append], locale_id: hash[:locale_id], base_url: base)).to eq(base + hash[:output])
      end
    end
  end

  it "base_url should handle urls as expected" do
    base_urls = [
      Capybara.app.config[:base_url],
      Capybara.app.config[:help_url],
      'https://foo.bar/'
    ]

    base_urls.each do |base|
      expectations.each do |hash|
        output = hash[:base_output] || hash[:output] # base_url does not care about the localize, so may have a different output
        expect(Capybara.app.base_url(hash[:append], base_url: base)).to eq(base + output)
      end
    end
  end

  it "localize_path should handle paths as expected" do
    # base_url does not care about the base url (https://) and just returns a relative, localized path
    expectations.each do |hash|
      expect(Capybara.app.localize_path(hash[:append], locale_id: hash[:locale_id])).to eq(hash[:output])
    end
  end
end
