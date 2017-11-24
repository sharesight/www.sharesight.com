require 'aws/s3'
require 'uri'

# TODO: Untested
# execute: S3RedirectsHelper::make_s3_redirects
#

module S3RedirectsHelper

  BASE_DIR_STUFF_TO_IGNORE = [
    ".", "..", "index.html", "sitemapindex.xml", "sitemap.xml", "robots.txt", "humans.txt",
    "google1decda79799cf179.html", "google1decda79799cf179.html.gz",
    "index.html.gz", "js", "fonts", "favicon.ico", "img", "patterns", "css",
    "BingSiteAuth.xml"
  ]

  def self.make_s3_redirects(dry_run = false)
    return unless ["staging", "production"].include?(ENV['APP_ENV']) && ENV['TRAVIS_PULL_REQUEST'] == "false"

    bucket_name = ::ApplicationConfig::S3::BUCKET

    make_connection
    base_dir_objects = Dir.entries("build") - BASE_DIR_STUFF_TO_IGNORE
    directory_queue = Queue.new
    base_dir_objects.each { |o| directory_queue << o }

    while !directory_queue.empty? do
      current_dir = directory_queue.pop

      Dir.entries(File.join("build", current_dir)).each do |object|
        full_name = File.join(current_dir, object)

        next if object.match /\.gz$/ # ignore these zipped pages
        next if object.match /^\.$/ # ignore .
        next if object.match /^\.\.$/ # ignore ..
        next if object.match /\.xml$/ # ignore the blog rss feed and any other xml files

        # if object is a directory, store it to read later
        directory_queue << full_name if File.directory?(full_name)

        # if object.matches current_dir/pages, redirect to current_dir/index.html
        if object.match(%r{pages$})
          create_redirect("#{full_name}", "/#{current_dir}/index.html", bucket_name, dry_run)
          create_redirect("#{full_name}/index.html", "/#{current_dir}/index.html", bucket_name, dry_run)
        elsif number = object.match(%r{(\d+)\.html$})
          # if object.matches SITE_BASE/current_dir/*.html
          create_redirect("/#{current_dir}/#{number[1]}", "/#{current_dir}/#{number[1]}.html", bucket_name, dry_run)
          create_redirect("/#{current_dir}/#{number[1]}/index.html", "/#{current_dir}/#{number[1]}.html", bucket_name, dry_run)
        elsif !object.match(%r{index\.html$})
          # add a "no trailing slash" redirect for the directory, using new S3
          # object of 'directory/index.html'
          create_redirect("/#{full_name}", "/#{full_name}/", bucket_name, dry_run)
        end
      end
      create_redirect("/#{current_dir}", "/#{current_dir}/", bucket_name, dry_run)
    end
  end

  def self.create_redirect(source_path, target_path, bucket_name, dry_run = false)
    create_redirect_file source_path, target_path, bucket_name, false, dry_run
  end

  # delete old redirect, if existing
  def self.create_redirect!(source_path, target_path, bucket_name, dry_run = false)
    create_redirect_file source_path, target_path, bucket_name, true, dry_run
  end

  def self.make_connection
    AWS::S3::Base.establish_connection!(
      access_key_id: ::ApplicationConfig::S3::ACCESS_ID,
      secret_access_key: ::ApplicationConfig::S3::SECRET_KEY
    )
  end

  private

  def self.create_redirect_file(source_path, target_path, bucket_name, override_existing = false, dry_run = false)
    if AWS::S3::S3Object.exists?(source_path, bucket_name)
      print "#{source_path} already exists "
      if override_existing
        puts "deleting old redirect..."
        AWS::S3::S3Object.delete(source_path, bucket_name) unless dry_run
      else
        puts "ignoring..."
        return
      end
    end
    puts "Creating a 301 redirect for object #{source_path} to #{target_path}"
    AWS::S3::S3Object.store(source_path, nil, bucket_name, 'x-amz-website-redirect-location': URI.encode(target_path), 'Content-Type': 'text/html') unless dry_run
  end
end
