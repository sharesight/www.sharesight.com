require 'spec_helper'

describe 'Landing Pages Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  context "landing_page_url" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_landing_pages().each do |landing_page|
        expect(@app.landing_page_url(landing_page)).to be_kind_of(::String)
      end
    end
  end

  context "landing_page_path" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_landing_pages().each do |landing_page|
        expect(@app.landing_page_path(landing_page)).to be_kind_of(::String)
      end
    end
  end

  context "landing_page_slug" do
    it "should work as expected" do
      get_landing_pages().each do |landing_page|
        expect(@app.landing_page_slug(landing_page)).to eq(landing_page[:url_slug])
      end
    end
  end

  context "landing_pages_collection" do
    it "should be an array of hashes" do
      data = @app.landing_pages_collection()
      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id)
      end
    end
  end
end
