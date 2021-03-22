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

      expect(posts.first[:created_at]).to be > posts.last[:created_at]

      expect(posts.length).to eq(@total_blog_posts)
    end

    it "is ordered by :latest_first by default" do
      posts = @app.blog_posts()

      expect(posts.first[:created_at]).to be > posts[1][:created_at]
      expect(posts.first[:created_at]).to be > posts[posts.length - 1][:created_at]

      expect(posts.length).to eq(@total_blog_posts)
    end

    it "can be ordered by :oldest_first" do
      posts = @app.blog_posts(order: :oldest_first)

      expect(posts.first[:created_at]).to be < posts[1][:created_at]
      expect(posts.first[:created_at]).to be < posts[posts.length - 1][:created_at]

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
