# Configuration
require 'config/contentful'

# Loading middleman helpers as these may change often.
load 'helpers/middleman/helpers.rb'
load 'helpers/basic_helper.rb'
load 'helpers/blog_helper.rb'
require 'helpers/s3_redirects_helper.rb'

require 'mappers/default'

load 'extensions/blog.rb'
load 'extensions/partners.rb'
load 'extensions/routing.rb'
require 'extensions/s3.rb'

require 'aws/s3'
require 'rack/rewrite'
require 'active_support/all'

config[:env_name] = ENV['APP_ENV'] || 'development'
config[:locale_name] = ENV['LOCALE'] || 'NZ'
config[:locale] = "en-#{config[:locale_name]}"

# Site Configuration
config[:site_name] = 'Sharesight'
config[:display_timezone] = 'Sydney' # Time.new.in_time_zone('Sydney')
config[:font_dir] = 'fonts'
config[:css_dir] = 'css'
config[:js_dir] = 'js'
config[:images_dir] = 'img'
config[:twitter_site_id] = '109123696'
config[:facebook_app_id] = '1028405463915894'
config[:ios_store_url] = 'https://itunes.apple.com/app/sharesight-reader/id1147841214?mt=8'
config[:google_store_url] = 'https://play.google.com/store/apps/details?id=com.sharesight.reader&hl=en'

config[:default_locale_id] = data.locales.find{|x| x[:id] == 'global' }[:id] # I understand this is weird, but I want to validate that `global` exists in the data too.
raise Exception.new("Missing the default locale, should be `global`.") if !config[:default_locale_id]

require "config/environments/#{config[:env_name]}" # ApplicationConfig comes from this.
config[:base_url] = ApplicationConfig::BASE_URL
config[:portfolio_url] = ApplicationConfig::PORTFOLIO_URL
config[:help_url] = ApplicationConfig::HELP_URL
config[:community_url] = ApplicationConfig::COMMUNITY_URL

# Auto-generate these from the portfolio url.
config[:api_url] = "#{config[:portfolio_url]}/api"
config[:signup_url] = "#{config[:portfolio_url]}/signup"
config[:login_url] = "#{config[:portfolio_url]}/login"
config[:pro_signup_url] = "#{config[:portfolio_url]}/professional_signup"

# Activate Middleman Extensions
activate :syntax, :line_numbers => true
activate :es6
activate :directory_indexes
activate :automatic_alt_tags
activate :autoprefixer do |autoprefixer_config|
  autoprefixer_config.browsers = [
    'last 5 versions',
    'Explorer >= 9'
  ]
  autoprefixer_config.cascade  = false
end

# Custom Middleman Extensions
activate :init_s3
activate :routing

# Fetch via Contentful
# NOTE: This must exist in this file, cannot be an extension as `middleman-contentful` doesn't appear to be able to initiate from any source other than config.rb.
# Do note, you MUST run `middleman contentful` prior to `middleman [build|server]` as contentful does not work properly with lifecycle hooks and data will be parsed post-configuration, pre-build (where other things can't hook into it)
[ ContentfulConfig::BlogSpace, ContentfulConfig::PartnersSpace ].each do |space|
  use_preview_api = config[:env_name] != 'production'
  contentful_access_token = (use_preview_api) && space::PREVIEW_ACCESS_TOKEN || space::ACCESS_TOKEN

  # This pulls the data from contentful and puts it into data[space::NAME][plural_name]
  activate :contentful do |f|
    f.use_preview_api   = use_preview_api # whether or not to use the drafts + published api
    f.access_token      = contentful_access_token # which token to use, only one has access to drafts –– redundant

    f.space             = { space::NAME => space::SPACE_ID }
    f.cda_query         = space::CDA_QUERY
    f.all_entries       = space::ALL_ENTRIES

    # This maps the content types; takes ['schema', 'array']; returns { 'schemas' => 'schema', 'arrays' => 'array' }
    f.content_types     = space::SCHEMAS.reduce(Hash.new(0)) { |memo, schema|
      mapper = ::DefaultMapper

      if schema.is_a?(Array)
        mapper = schema[1]
        schema = schema[0]
      end

      memo[schema.pluralize(2)] = { id: schema, mapper: mapper }
      memo # return
    }
  end
end

# activate :pagination
activate :blog_space # creates the pagination
activate :partners_space # creates the pagination

# Sync to S3.  Unfortunately this doesn't appear to like any lifecycles either and isn't working in an extension.
if ApplicationConfig.const_defined?(:S3)
  activate :s3_sync do |s3_sync|
    s3_sync.bucket                     = ApplicationConfig::S3::BUCKET # The name of the S3 bucket you are targeting. This is globally unique.
    s3_sync.region                     = 'us-east-1'     # The AWS region for your bucket.
    s3_sync.aws_access_key_id          = ApplicationConfig::S3::ACCESS_ID
    s3_sync.aws_secret_access_key      = ApplicationConfig::S3::SECRET_KEY

    s3_sync.delete                     = false
    s3_sync.after_build                = false # We do not chain after the build step by default.
    s3_sync.prefer_gzip                = true
    s3_sync.path_style                 = true
    s3_sync.reduced_redundancy_storage = false
    s3_sync.acl                        = 'public-read'
    s3_sync.encryption                 = false
  end

  default_caching_policy                    max_age: (60 * 60 * 24 * 365), public: true
  caching_policy 'text/html',               max_age: (60 * 15), public: true, must_revalidate: true
  caching_policy 'application/xml',         max_age: (60 * 15), public: true
  caching_policy 'application/javascript',  max_age: (60 * 15), public: true

  activate :cloudfront do |cf|
    cf.access_key_id = ApplicationConfig::S3::ACCESS_ID
    cf.secret_access_key = ApplicationConfig::S3::SECRET_KEY
    cf.distribution_id = ApplicationConfig::S3::CLOUDFRONT_DIST_ID
    cf.filter = /\.html$/i
  end
end

# Activate Custom Middleman Helpers
helpers MiddlemanHelpers # includes every helper in helpers/middleman/*

# Build-specific configuration
configure :build do
  activate :gzip do |gzip|
    gzip.exts = %w(.js .css .html .htm .svg .txt .ico)
  end

  remove_paths = ['.DS_Store']
  remove_paths << 'ca/lp-general-ca' if config[:env_name] == 'production'
  activate :remover, :paths => remove_paths

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript
  config[:js_compressor] = Uglifier.new()

  # Enable cache buster
  activate :asset_hash, :ignore => [/touch-icon/, /opengraph/]

  activate :minify_html do |html|
    html.remove_http_protocol    = false
    html.remove_input_attributes = false
    html.remove_quotes           = true
    html.remove_intertag_spaces  = true
  end
end
