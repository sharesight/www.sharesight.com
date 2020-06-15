require 'spec_helper'

describe 'Landing Pages Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  describe "landing_page_url" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_landing_pages.each do |landing_page|
        expect(@app.landing_page_url(landing_page)).to be_a(String)
      end
    end
  end

  describe "landing_page_path" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_landing_pages().each do |landing_page|
        expect(@app.landing_page_path(landing_page)).to be_a(String)
      end
    end
  end

  describe "landing_page_slug" do
    it "should work as expected" do
      get_landing_pages().each do |landing_page|
        expect(@app.landing_page_slug(landing_page)).to eq(landing_page[:url_slug])
      end
    end
  end

  describe 'landing_page_title' do
    subject { @app.landing_page_title(landing_page) }

    let(:landing_page) { get_landing_pages.sample }

    it 'should append the correct locale string' do
      expect(subject).to end_with('| Sharesight')
    end

    context 'For Australia' do
      subject { @app.landing_page_title(landing_page, locale_obj: locale_obj) }

      let(:locale_obj) { double('Locale') }

      before do
        allow(locale_obj).to receive(:[]).with(:append_title).and_return('| Sharesight Australia')
      end

      it 'should append the correct locale string' do
        expect(subject).to end_with('| Sharesight Australia')
      end
    end
  end

  describe "landing_pages_collection" do
    it "should be an array of hashes" do
      data = @app.landing_pages_collection()
      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id)
        expect(a).to include(:description)
      end
    end
  end
end
