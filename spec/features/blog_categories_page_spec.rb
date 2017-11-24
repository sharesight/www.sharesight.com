require 'spec_helper'

describe 'Blog Category Pages', :type => :feature do
  before :all do
    @categories = get_blog_categories(all: true)
    @per_page = 16
  end

  it "should load" do
    @categories.each do |category|
      visit category[:path]

      expect(page).to respond_successfully
    end
  end

  it "should have expected meta tags" do
    @categories.each do |category|
      visit category[:path]

      expect(page).to have_base_metas()
      expect(page).to have_social_metas()
      expect(page).to have_titles(category.page_title)
      expect(page).to have_descriptions(category[:description])
    end
  end

  it "should have expected urls" do
    @categories.each do |category|
      subset = 0
      while (category.posts.length - subset > 0) do
        subset += @per_page
        page_num = subset/@per_page
        page_url = category[:path]
        page_url += "pages/#{page_num}" if page_num > 1
        page_url = base_path(page_url)

        visit page_url

        expect(page).to respond_successfully

        expect(page).to have_head('link', args: { rel: 'canonical', href: absolute_url(page_url) }, debug: :href)
        expect(page).to have_head('link', args: { rel: 'alternate', href: base_url('blog/feed.xml') }, debug: :href)
        expect(page).to have_meta('og:url', base_url(category[:path]), name_key: 'property') # no /pages/2...stuff

        prev = nil # reset on each loop
        prev = base_url("#{category[:path]}/pages/#{page_num - 1}/") if page_num >= 3
        prev = category[:url] if page_num == 2
        expect(page).to have_head('link', args: { rel: 'prev', href: prev }, debug: :href) if prev
        expect(page).to have_head('link', args: { rel: 'next', href: base_url("#{category[:path]}/pages/#{page_num + 1}/") }, debug: :href) if category.posts.length - subset > 0
      end
    end
  end

  it "should have the expected elements" do
    @categories.each do |category|
      visit category[:path]

      expect(page).to have_css('a.breadcrumb', text: 'Blog') unless category.name == 'All'

      expect(page).to have_css('h1.heading', text: (category.name == 'All') ? category.title : "Topic: #{category.title}")

      # Expect this to have posts.
      expect(page).to have_selector(:css, 'a.btn', text: 'Read Full Post', count: category.posts.length > @per_page ? @per_page : category.posts.length)

      # Check for the navigation on the right.
      expect(page).to have_css('h4', text: 'Topics')
      @categories.each do |cat|
        expect(page).to have_css("nav[role='navigation'] li a[href='#{cat.url}']", text: "#{cat.title} (#{cat.posts.length})") unless cat.name == 'All'
      end

      # Check for the next page.
      expect(page).to have_css("a[href='#{base_url("#{category[:path]}/pages/2/")}']", text: 'Older posts') if category.posts.length > @per_page

      # Have a footer.
      expect(page).to have_css('.footer__copyright', text: 'All rights reserved.')
    end
  end
end
