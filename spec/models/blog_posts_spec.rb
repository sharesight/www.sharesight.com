require 'spec_helper'

describe 'Blog Posts', :type => :model do
  before :all do
    @data = Capybara.app.data.blog.posts
    @collection = get_blog_posts()
  end

  it "should have a directory" do
    page_data_dir = dir_list("data/blog/posts")
    expect(page_data_dir - [".", ".."]).not_to be_empty
  end

  it "should have a list of tuples as data array" do
    @data.each do |tuple|
      expect(tuple).to be_kind_of(Array)
      expect(tuple[0]).to be_kind_of(String)
      expect(tuple[1]).not_to be_falsey
    end
  end

  it "should have data in middleman" do
    expect(@data).not_to be_empty
    expect(@collection).not_to be_empty
  end

  it "should have unique blog titles" do
    expect(@collection.map{ |model| model[:title] }.uniq.count).to eq(@collection.count)
  end

  it "should have unique blog urls" do
    expect(@collection.map{ |model| BlogHelper.url_slug(model) }.uniq.count).to eq(@collection.count)
  end

  it "should have the required schema fields" do
    schema = @collection.map{ |x| x.to_h.keys }.flatten.uniq # list of all keys in all models
    schema = schema.map{ |x| x.to_sym }

    expect(schema).to include(
      :id, :_meta, :title, :content, :author, :categories, :created_at,
      :meta_description, :featured_image, :wordpress_url
    )
  end
end
