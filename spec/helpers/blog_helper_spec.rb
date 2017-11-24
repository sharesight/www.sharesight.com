require 'spec_helper'

describe 'Blog Helper', :type => :helper do
  before :all do
    @posts = get_blog_posts()
  end

  context "url slug" do
    it "should return expected values" do
      [ # These should SUCCEED.
        ['sharesight-mobile-app--april-2017-update', 'Sharesight Mobile App - April 2017 update'],
        ['foo-bar', ' Foo Bar'],
        ['2017', ' 2017 '],
        ['foo--bar', ' foo --  bar']
      ].each do |arr|
        fake_post = OpenStruct.new(title: arr[1], wordpress_url: '')
        expect(arr[0]).to eq(BlogHelper::url_slug(fake_post))
      end

      [ # These should FAIL.
        ['sharesight-mobile-app-april-2017-update', 'Sharesight Mobile App - April 2017 update'],
        ['foo--bar', ' Foo  Bar'],
        ['2017 ', ' 2017 '],
        ['foo-bar', ' foo --  bar']
      ].each do |arr|
        fake_post = OpenStruct.new(title: arr[1], wordpress_url: '')
        expect(arr[0]).not_to eq(BlogHelper::url_slug(fake_post))
      end
    end

    it "should return the correct url when a wordpress_url is provided" do
      @posts.select{ |post| post.wordpress_url&.present? }.each do |post|
        expect(BlogHelper::url_slug(post)).to eq(BlogHelper::url_slug_from_wordpress_url(post[:wordpress_url]))
      end
    end

    it "should return the correct url when a wordpress_url is not provided" do
      @posts.select{ |post| !post.wordpress_url&.present? }.each do |post|
        expect(BlogHelper::url_slug(post)).to eq(BlogHelper::url_slug_from_title(post[:title]))
      end
    end
  end

  context "valid post" do
    it "should be valid" do
      [
        OpenStruct.new({ title: 'title', author: { name: 'name' }, featured_image: { url: 'url' } }),
        OpenStruct.new({ title: 'title', author: { name: 'name' }, featured_image: { url: 'url' }, wordpress_url: 'foo-bar' }),
      ].each do |obj|
        expect(BlogHelper.is_valid_post?(obj)).to be(true)
      end
    end

    it "should be invalid" do
      [
        OpenStruct.new({ title: ' ', author: { name: 'name' }, featured_image: { url: 'url' }, wordpress_url: 'foo-bar' }),
        OpenStruct.new({ id: '123' }),
        OpenStruct.new({ title: 'title', author: {}, featured_image: {} }),
        OpenStruct.new({ title: 'title', author: {}, featured_image: {} }),
        OpenStruct.new({ title: '', author: [], featured_image: { url: 'url' } }),
        OpenStruct.new({ title: 'title' }),
      ].each do |obj|
        expect(BlogHelper.is_valid_post?(obj)).to be(false)
      end
    end
  end

  context "valid category" do
    it "should be valid" do
      [
        OpenStruct.new({ name: 'string' }),
        OpenStruct.new({ name: 'string' })
      ].each do |obj|
        expect(BlogHelper.is_valid_category?(obj)).to be(true)
      end
    end

    it "should be invalid" do
      [
        OpenStruct.new({ id: '123' }),
        OpenStruct.new({ name: '' }),
        OpenStruct.new({ name: ' ' }),
        OpenStruct.new({ name: nil }),
        OpenStruct.new({ name: false })
      ].each do |obj|
        expect(BlogHelper.is_valid_category?(obj)).to be(false)
      end
    end
  end
end
