require 'spec_helper'

describe 'Blog Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  context "post_url" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_blog_posts().each do |post|
        expect(@app.post_url(post)).to be_kind_of(::String)
      end
    end
  end

  context "blog_categories" do
    it "should be an array of hashes" do
      data = @app.blog_categories()

      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id, :name, :path, :description, :count, :set)
      end
    end
  end
end
