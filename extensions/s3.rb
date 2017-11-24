require 'aws/s3'
require 'helpers/s3_redirects_helper'

module Middleman
  class HandleS3 < Extension
    def initialize(app, options_hash={}, &block)
      super
    end

    def after_build
      if ['staging', 'production'].include?(app.config[:env_name]) && ENV['TRAVIS_PULL_REQUEST'] == "false"
        puts "after_build: updating 301 redirects"
        S3RedirectsHelper::make_s3_redirects
      else
        puts "after_build: skipping 301 redirect update"
      end
    end
  end
end

::Middleman::Extensions.register(:init_s3, ::Middleman::HandleS3)
