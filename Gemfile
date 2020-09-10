source 'https://rubygems.org'

gem 'rake'
gem 'middleman', '~> 3.4.1'
# gem 'middleman'
gem 'middleman-livereload'
gem 'middleman-s3_sync', '~> 3.0'
gem 'middleman-cloudfront'
gem 'middleman-autoprefixer'
gem 'middleman-minify-html'
gem 'middleman-sprockets'
gem "middleman-es6", git: "https://github.com/vast/middleman-es6"
# gem 'babel-transpiler'
gem 'uglifier'
# gem "contentful_middleman", '~> 2.1.2'
gem "contentful_middleman", '3.0.1'
# gem "contentful_middleman"
gem 'middleman-pagination'
gem 'middleman-remover'
gem 'middleman-syntax'
gem 'string-urlize'
gem 'aws-s3'

# support re-writing in the middleman configuration
gem 'rack-rewrite'

# support whitelist-sanitizing content (remove script-tags, etc.)
gem 'rails-html-sanitizer'

# tests
group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'chromedriver-helper' # for headless chrome
  gem 'rspec'
  gem 'guard-rspec', require: false
end

group :development, :test do
  # gem 'byebug'
  gem "bundle-audit"
end
