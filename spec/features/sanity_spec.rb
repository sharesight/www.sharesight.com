require 'spec_helper'

describe 'Build Sanity', :type => :feature do
  it "should have built a site" do
    root_dir = dir_list("build")
    # technical assets directories
    expect(root_dir).to include("js")
    expect(root_dir).to include("img")
    expect(root_dir).to include("css")

    # files only in root directory
    expect(root_dir).to include("favicon.ico")
    expect(root_dir).to include(match(/favicon-16x16-[A-f0-9]+\.png/)) # is hashed
    expect(root_dir).to include(match(/favicon-32x32-[A-f0-9]+\.png/)) # is hashed
    expect(root_dir).to include("robots.txt")
    expect(root_dir).to include("sitemap.xml")
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
