require 'spec_helper'

describe 'Blog Categories', :type => :model do
  before :all do
    @data = Capybara.app.data.blog.categories
    @collection = get_blog_categories()
  end

  it "should have a directory" do
    page_data_dir = dir_list("data/blog/categories")
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

  it "should have unique titles" do
    expect(@collection.map{ |model| model[:name] }.uniq.count).to eq(@collection.count)
  end

  it "should have unique urls" do
    expect(@collection.map{ |model| Capybara.app.url_friendly_string(model[:name]) }.uniq.count).to eq(@collection.count)
  end

  it "should have the required schema fields" do
    schema = @collection.map{ |x| x.to_h.keys }.flatten.uniq # list of all keys in all models
    schema = schema.map{ |x| x.to_sym }

    expect(schema).to include(:id, :_meta, :name)
  end
end
