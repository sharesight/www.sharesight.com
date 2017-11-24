require 'spec_helper'

describe 'Blog Authors', :type => :model do
  before :all do
    @data = Capybara.app.data.blog.authors
    @collection = get_blog_authors()
  end

  it "should have a directory" do
    page_data_dir = dir_list("data/blog/authors")
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

  it "should have the required schema fields" do
    schema = @collection.map{ |x| x.to_h.keys }.flatten.uniq # list of all keys in all models
    schema = schema.map{ |x| x.to_sym }

    expect(schema).to include(:id, :_meta, :display_name, :first_name, :last_name, :title, :company)
  end
end
