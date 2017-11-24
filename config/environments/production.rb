module ApplicationConfig
  APP_ENV = 'production'
  BASE_URL = 'https://www.sharesight.com'
  PORTFOLIO_URL = 'https://portfolio.sharesight.com'
  HELP_URL = 'https://help.sharesight.com'
  COMMUNITY_URL = 'https://community.sharesight.com'

  module GoogleAnalytics
    TRACKING_KEY = 'UA-807390-15'
    OPTIMIZE_CONTAINER = 'GTM-K7956NL'
    TAG_MANAGER_CONTAINER = 'GTM-5HSWD9'
  end

  module Bugsnag
    API_KEY = ENV['BUGSNAG_API_KEY']
  end

  module S3
    BUCKET = 'middleman-www'
    ACCESS_ID = ENV['AWS_DEPLOY_ACCESS_ID']
    SECRET_KEY = ENV['AWS_DEPLOY_SECRET_KEY']
    CLOUDFRONT_DIST_ID = 'E24W7GYQHUS6J7'
  end
end
