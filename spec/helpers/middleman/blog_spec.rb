require 'spec_helper'

describe 'Blog Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
    @posts_data = Capybara.app.data.blog.posts.values
    @total_blog_posts = @posts_data.length
  end

  context "blog_posts" do
    it "should have the expected length of blog posts" do
      posts = @app.blog_posts

      expect(posts.length).to eq(@total_blog_posts)
    end

    it "can be ordered by :latest_first" do
      posts = @app.blog_posts(order: :latest_first)

      # The newest blog post is probably always this or the previous year…probably.
      expect(posts.first[:created_at].year).to be >= Time.now.year - 1
      # The oldest blog post is from 2007.
      expect(posts.last[:created_at].year).to be(2007)

      expect(posts.first[:created_at].to_i).to be >= posts[1][:created_at].to_i
      expect(posts.first[:created_at].to_i).to be >= posts[posts.length - 1][:created_at].to_i

      expect(posts.length).to eq(@total_blog_posts)
    end

    it "is ordered by :latest_first by default" do
      posts_default = @app.blog_posts()
      posts_latest_first = @app.blog_posts(order: :latest_first)

      expect(posts_default).to eq(posts_latest_first)
    end

    it "can be ordered by :oldest_first" do
      posts = @app.blog_posts(order: :oldest_first)

      # The oldest blog post is from 2007.
      expect(posts.first[:created_at].year).to be(2007)
      # The newest blog post is probably always this or the previous year…probably.
      expect(posts.last[:created_at].year).to be >= Time.now.year - 1

      expect(posts.first[:created_at].to_i).to be <= posts[1][:created_at].to_i
      expect(posts.first[:created_at].to_i).to be <= posts[posts.length - 1][:created_at].to_i

      expect(posts.length).to eq(@total_blog_posts)
    end

    it "can be unordered (no use-case)" do
      posts = @app.blog_posts(order: nil)

      # The unordered posts match the dataset (which may or may not have an order)
      expect( posts[0][:id]).to eq(@posts_data[0][:id])
      expect(posts[posts.length - 1][:id]).to eq(@posts_data[posts.length - 1][:id])

      expect(posts.length).to eq(@total_blog_posts)
    end
  end

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
      get_blog_posts(order: :latest_first, limit: 10).each do |post|
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
