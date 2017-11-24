require 'spec_helper'

describe 'Blog', :type => :model do
  before :all do
    @data = Capybara.app.data.blog
  end

  it "should have a directory" do
    page_data_dir = dir_list("data/blog")
    expect(page_data_dir - [".", ".."]).not_to be_empty
  end

  it "should have data in middleman" do
    expect(@data).not_to be_empty
  end
end
