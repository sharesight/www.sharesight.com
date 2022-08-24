require 'spec_helper'

describe 'URL Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
    @url = Capybara.app.config[:base_url]
    @external_url = 'https://fake.test.whatever'
  end

  context "get_current_page_url" do
    it "should strip out pages/number" do
      skip "This does not work – Middleman does not seem to update the `current_page`.."
    end
  end

  context "current_global_url" do
    it "should be the current absolute url" do
      skip "This does not work – Middleman does not seem to update the `current_page`.."

      visit @url + '/'
      expect(Capybara.app.current_global_url).to eq(@url)
    end
  end

  context "absolute_url" do
    it "should return if already providing a full url" do
      expect(@app.absolute_url(@url)).to eq(@url)
    end

    it "should strip out .html" do
      expect(@app.absolute_url('something.html')).to eq(@url + '/something/')
    end

    it "should return no trailing slash when no path" do
      expect(@app.absolute_url('')).to eq(@url)
    end

    it "should return an absolute url with a different base" do
      expect(@app.absolute_url('', base_url: @external_url)).to eq(@external_url)
      expect(@app.absolute_url('/nz/faq', base_url: @external_url)).to eq(@external_url + '/nz/faq/')
    end
  end

  context "url_friendly_string" do
    it "should proxy to basic helper" do
      [
        ' one-1 one ONe _-_ 12-   -f a / ',
        'Just a normal title',
        'Just a normal  title ',
      ].each do |title|
        expect(@app.url_friendly_string(title)).to eq(BasicHelper::url_friendly_string(title))
      end
    end
  end

  context "base_path" do
    it "should match our expectations" do
      [
        ['/ca/', ''],
        ['/ca', ''],
        ['/', '']
      ].each do |assume, expect|
        expect(@app.base_path(assume)).to eq(expect)
        expect(@app.unlocalized_path(assume)).to eq(expect)
      end
    end
  end

  context "base_url" do
    it "should match our expectations" do
      [
        ['/ca/', @url],
        ['/ca', @external_url, @external_url],
        ['/', @url]
      ].each do |arr|
        assume = arr[0]
        expect = arr[1]
        url = arr[2]
        url ||= @url
        expect(@app.base_url(assume, base_url: url)).to eq(expect)
        expect(@app.unlocalized_url(assume, base_url: url)).to eq(expect)
      end
    end
  end

  context "localize_path" do
    it "should match our expectations" do
      [
        ['/ca/', ''],
        ['/', ''],
        ['/ca', '/nz/', 'nz'],
        ['/', '/nz/', 'nz']
      ].each do |arr|
        assume = arr[0]
        expect = arr[1]
        locale_id = arr[2]
        locale_id ||= default_locale_id
        expect(@app.localize_path(assume, locale_id: locale_id)).to eq(expect)
      end
    end
  end

  context "localize_url" do
    it "should match our expectations" do
      [
        ['/ca/', @url],
        ['/ca', @external_url + '/nz/', 'nz', @external_url],
        ['/', @url + '/nz/', 'nz'],
        ['path', 'https://something.without.slash/path/', nil, 'https://something.without.slash'],
        ['', 'https://help.sharesight.com/', 'us', 'https://help.sharesight.com/'], # should not attach :us locale to help-site (US doens't exist yet)
      ].each do |arr|
        append = arr[0]
        expect = arr[1]
        locale_id = arr[2]
        locale_id ||= default_locale_id
        url = arr[3]
        url ||= @url
        expect(@app.localize_url(append, locale_id: locale_id, base_url: url)).to eq(expect)
      end
    end
  end

  context "page_from_path" do
    it "should match our expectations" do
      [
        ['/nz/fake-page', 'fake-page'],
        ['/nz/faq', 'faq'],
        ['/faq', 'faq'],
        ['faq', 'faq'],
        ['/ug/faq', 'ug'], # bad "locale id"
      ].each do |assume, expect|
        expect(@app.page_from_path(assume)).to eq(expect)
      end
    end
  end

  context "wrap_path_in_slashes" do
    it "should match our expectations" do
      [
        ['whatever', '/whatever/'],
        ['////faq///', '/faq/'],
        ['foo?bar', '/foo?bar'],
        ['foo#bar', '/foo#bar'],
        ['foo.xml', '/foo.xml'],
        ['foo&bar', '/foo&bar'], # actually wrong?, but assuming & implies ?
        ['foo-bar', '/foo-bar/'],
        ['foo\bar', '/foo\bar/'],
        ['foo__bar', '/foo__bar/']
      ].each do |assume, expect|
        expect(@app.wrap_path_in_slashes(assume)).to eq(expect)
      end
    end
  end

  context "trim_wrapped_slashes" do
    it "should match our expectations" do
      [
        ['whatever', 'whatever'],
        ['//a//faq///', 'a//faq'], # doesn't even touch anything unless it's in the start/end
        ['foo?bar', 'foo?bar'],
        ['foo#bar', 'foo#bar'],
        ['/foo.xml/', 'foo.xml'],
        ['foo/&bar', 'foo/&bar'],
        ['foo-bar/', 'foo-bar'],
        ['foo\bar', 'foo\bar'],
        ['foo__bar/', 'foo__bar'],
        ['foo__bar/anything/whatever', 'foo__bar/anything/whatever']
      ].each do |assume, expect|
        expect(@app.trim_wrapped_slashes(assume)).to eq(expect)
      end
    end
  end

  context "strip_html_from_path" do
    it "should remove .html from the path" do
      [
        # input, # output
        ['', ''],
        ['.html', ''],
        ['/', '/'],
        ['/nz.html', '/nz'],
      ].each do |array|
        expect(@app.strip_html_from_path(array[0])).to eq(array[1])
      end
    end
  end

  context "strip_locale_from_path" do
    it "should remove the locale from the path" do
      [
        # input, # output
        ['/nz', '/'],
        ['/nz/faq/', '/faq/'],
        ['/eu/faq', '/eu/faq/']
      ].each do |array|
        expect(@app.strip_locale_from_path(array[0])).to eq(array[1])
      end
    end
  end

  context "strip_pagination_from_path" do
    it "should remove /pages/# from the path" do
      [
        # input, # output
        ['', '/'],
        ['/', '/'],
        ['/nz/pages/2/', '/nz/'],
        ['/pages/2.html', '/'],
        ['/some-pages/2.html', '/some-pages/2/'],
        ['/some-pages/0f.html', '/some-pages/0f/'],
      ].each do |array|
        expect(@app.strip_pagination_from_path(array[0])).to eq(array[1])
      end
    end
  end

  context "image_url" do
    it "should create an image url for external links" do
      skip "Add testing."
    end
  end

  context "is_remote_url?" do
    ['ftp', 'ws', 'ssh'].each do |scheme|
      it "should be true for scheme=#{scheme}" do
        url = "#{scheme}://#{Capybara.app.config[:base_url]}/faq/"

        expect(Capybara.app.is_remote_url?(url)).to be true
      end
    end

    [
      Capybara.app.config[:base_url],
      Capybara.app.config[:base_url],
      "#{Capybara.app.config[:base_url]}/faq/",
      "#{Capybara.app.config[:base_url]}/weird.path.com/"
    ].each do |url|
      it "should be false when the host matches our base url, testing #{url}" do
        expect(Capybara.app.is_remote_url?(url)).to be false
      end
    end

    [
      Capybara.app.config[:help_url],
      Capybara.app.config[:portfolio_url],
      "https://wwww.sharesight.com/", # too many ws!
      "https://www.sharesight.com.hacking.us/", # bad host
    ].each do |url|
      it "should be true for a different host, testing #{url}" do
        expect(Capybara.app.is_remote_url?(url)).to be true
      end
    end

    [
      "/faq/",
      "/",
      "",
      "#anchor-tag",
      "?query=string",
      "javascript:;",
      "maito:sales@sharesight.com",
    ].each do |url|
      it "should be false when there is no host, testing #{url}" do
        expect(Capybara.app.is_remote_url?(url)).to be false
      end
    end
  end

  context "is_third_party_url?" do
    [
      Capybara.app.config[:base_url],
      Capybara.app.config[:help_url],
      Capybara.app.config[:portfolio_url],
      "https://wwwwwww.sharesight.com/",
      "https://any.other.domain.sharesight.com/",
      "https://sharesight.com/",
    ].each do |url|
      it "should be false for a sharesight ecosystem host, testing #{url}" do
        expect(Capybara.app.is_third_party_url?(url)).to be false
      end
    end

    [
      "https://www.google.com/",
      "https://www.notsharesight.com/",
      "https://www.sharesight.co.nz/", # not whitelisted, even though we own it
      "https://www.sharesight.io/",
      "https://www.sharesight.com.hacking.us/",
    ].each do |url|
      it "should be true for a different host, testing #{url}" do
        expect(Capybara.app.is_third_party_url?(url)).to be true
      end
    end

    [
      "/faq/",
      "/",
      "",
      "#anchor-tag",
      "?query=string",
      "javascript:;",
      "maito:sales@sharesight.com",
    ].each do |url|
      it "should be false when there is no host, testing #{url}" do
        expect(Capybara.app.is_third_party_url?(url)).to be false
      end
    end
  end
end
