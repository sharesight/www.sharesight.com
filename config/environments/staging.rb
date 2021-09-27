module ApplicationConfig
  APP_ENV = 'staging'
  BASE_URL = 'https://staging-www.sharesight.com'
  PORTFOLIO_URL = 'https://test-portfolio.sharesight.com'
  HELP_URL = 'https://staging-help.sharesight.com'
  COMMUNITY_URL = 'https://test-community.sharesight.com'

  module GoogleAnalytics
    TAG_MANAGER_CONTAINER = 'GTM-P2DH5X'
  end
  
	module Intercom
    APP_ID = 't2bi7urt'
  end

	module Bugsnag
		API_KEY = ENV['BUGSNAG_API_KEY']
	end

  module AddThis
    ID = 'ra-5b7f54d2f27cd7c1'
  end

  module S3
    BUCKET = 'staging-middleman-www'
    ACCESS_ID = ENV['AWS_DEPLOY_ACCESS_ID']
    SECRET_KEY = ENV['AWS_DEPLOY_SECRET_KEY']
    CLOUDFRONT_DIST_ID = 'E57A7O2HKWUL9'
  end
end
