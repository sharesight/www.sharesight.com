module ApplicationConfig
  APP_ENV = 'production'
  BASE_URL = 'https://www.sharesight.com'
  PORTFOLIO_URL = 'https://portfolio.sharesight.com'
  HELP_URL = 'https://help.sharesight.com'
  COMMUNITY_URL = 'https://community.sharesight.com'

  module GoogleAnalytics
    TAG_MANAGER_CONTAINER = 'GTM-5HSWD9'
  end
  
  module Intercom
    APP_ID = 'tv6jsyee'
  end

  module AddThis
    ID = 'ra-5b7e0717fea453d4'
  end

  module S3
    BUCKET = 'middleman-www'
    ACCESS_ID = ENV['AWS_DEPLOY_ACCESS_ID']
    SECRET_KEY = ENV['AWS_DEPLOY_SECRET_KEY']
    CLOUDFRONT_DIST_ID = 'E24W7GYQHUS6J7'
  end
end
