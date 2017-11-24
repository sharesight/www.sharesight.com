require 'cgi'
require 'spec_helper'

describe 'Blog Post Pages', :type => :feature do
  before :all do
    @posts = get_blog_posts()
    @categories = get_blog_categories(all: true)
  end

  it "should load" do
    @posts.each do |post|
      visit post.path

      expect(page).to respond_successfully
    end
  end

  it "should have expected base metas" do
    @posts.each do |post|
      visit post.path

      expect(page).to have_base_metas()
      expect(page).to have_social_metas()
      expect(page).to have_titles(post.page_title)
      expect(page).to have_descriptions(post.meta_description)
    end
  end

  it "should have expected facebook metas" do
    @posts.each do |post|
      visit post.path

      expect(page).to have_meta('og:type', 'article', name_key: 'property')
    end
  end

  it "should have expected urls" do
    @posts.each do |post|
      visit post.path

      expect(page).to have_head('link', args: { rel: 'canonical', href: URI::unescape(post.url) }, debug: :href)
      expect(page).to have_meta('og:url', URI::unescape(post.url), name_key: 'property')

      expect(page).to have_head('link', args: { rel: 'alternate', href: base_url('blog/feed.xml') }, debug: :href)
    end
  end

  it "should have the expected elements" do
    @posts.each do |post|
      visit post.path

      expect(page).to have_css('a.breadcrumb', text: 'Blog')

      expect(page).to have_css('h1', text: post.title)

      # Check for the navigation on the right.
      expect(page).to have_css('h4', text: 'Topics')
      @categories.each do |cat|
        expect(page).to have_css("nav[role='navigation'] li a[href='#{cat.url}']", text: "#{cat.title} (#{cat.posts.length})") unless cat.name == 'All'
      end

      # Have a footer.
      expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
    end
  end
end
