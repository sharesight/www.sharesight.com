require 'spec_helper'

describe 'Build Sanity', :type => :feature do
  it "should have data from Contentful" do
    page_data_dir = dir_list("data/blog/posts/")
    expect(page_data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data.blog.posts.length).to be > 0

    data_dir = dir_list("data/blog/authors/")
    expect(data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data.blog.authors.length).to be > 0

    data_dir = dir_list("data/blog/categories/")
    expect(data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data.blog.categories.length).to be > 0

    data_dir = dir_list("data/partners/partners/")
    expect(data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data.partners.partners.length).to be > 0

    data_dir = dir_list("data/partners/categories/")
    expect(data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data.partners.categories.length).to be > 0

    data_dir = dir_list("data/landing-pages/pages/")
    expect(data_dir - [".", ".."]).not_to be_empty
    expect(Capybara.app.data['landing-pages'].pages.length).to be > 0
  end

  it "should have built a site" do
    root_dir = dir_list("build")
    # technical assets directories
    expect(root_dir).to include("js")
    expect(root_dir).to include("img")
    expect(root_dir).to include("css")

    # directories only in root directory
    expect(root_dir).to include("blog")

    # files only in root directory
    expect(root_dir).to include("favicon.ico")
    expect(root_dir).to include(match(/favicon-16x16-[A-f0-9]+\.png/)) # is hashed
    expect(root_dir).to include(match(/favicon-32x32-[A-f0-9]+\.png/)) # is hashed
    expect(root_dir).to include("robots.txt")
    expect(root_dir).to include("sitemap.xml")

    ['', 'au', 'ca', 'nz', 'uk'].each do |locale_id|
      expect(root_dir).to include(locale_id) if locale_id != ''
      dir = dir_list("build/#{locale_id}")
      expect(dir).to include("index.html")
      expect(dir).to include("partners")
      expect(dir).to include("pro")
      expect(dir).to include("xero")
    end

    Capybara.app.data.locales.each do |locale|
      get_landing_pages(locale).each do |landing_page|
        locale_id = locale[:id]
        locale_id = '' if locale_id == 'global' # we're looking at the build directory
        dir = dir_list("build/#{locale_id}")
        expect(dir).to include("#{landing_page[:url_slug]}")
      end
    end
  end

  it "should not include git conflict markers in source" do # checks for <<<<<<< (7 of those)
    ignore_files = [ "favicon.ico", ".woff", ".jpg", ".png", ".mp4", ".webm", ".mov" ] # ignore non-texty files
    Find.find(File.expand_path(File.dirname(__FILE__) + "/../../source")) do |path|
      if ignore_files.none? { |ignore| path.match(ignore)  } && FileTest.file?(path)
        begin
          expect(File.foreach(path).grep(/(\<{7}|\>{7})/)).to be_empty
        rescue ArgumentError => e
          if e.message.match("invalid byte sequence in UTF-8")
            puts "ignoring binary file #{path}"
          end
        end
      end
    end
  end
end
