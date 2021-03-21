require 'spec_helper'

describe 'Blog Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app

  context "blog_posts_for_menu" do
    it "should have 3 blog posts in it" do
      posts = @app.blog_posts_for_menu

      expect(posts.length).to eq(3)
    end

    it "all blog posts should be in expected categories" do
      category_name_regexes = [
        /Company News/,
        /Investing Tips/,
        /Release Notes/,
        /Sharesight Features .* Tips/
      ]

      posts = @app.blog_posts_for_menu
      posts.each do |post|
        has_expected_category = post.categories.any? do |category|
          category_name_regexes.any? do |name_regex|
            category[:name] =~ name_regex
          end
        end

        expect(has_expected_category).to eq(true)
      end
    end
  end

  context "post_url" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_blog_posts(order: :youngest_first, limit: 10).each do |post|
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
