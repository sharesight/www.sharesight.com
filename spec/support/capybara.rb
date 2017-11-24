require 'ostruct'

require 'rspec/core'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara/rspec/matchers'
require 'capybara/rspec/features'
require 'selenium-webdriver'

require 'middleman-core'

# Load support helpers
Dir[File.join(File.dirname(__FILE__), 'helpers', '**', '*.rb')].each{ |file| require_relative file }

module CapybaraHelpers
  include ::CapybaraBaseHelpers
  include ::CapybaraBlogHelpers
  include ::CapybaraFileHelpers
  include ::CapybaraLocaleHelpers
  include ::CapybaraPageHelpers
  include ::CapybaraPartnersHelpers
  include ::CapybaraUrlHelpers
end

# Portions taken from https://github.com/middleman/middleman/issues/1726#issuecomment-169281603

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.include CapybaraHelpers

  # A work-around to support accessing the current example that works in both
  # RSpec 2 and RSpec 3.
  fetch_current_example = RSpec.respond_to?(:current_example) ?
    proc { RSpec.current_example } : proc { |context| context.example }

  # The before and after blocks must run instantaneously, because Capybara
  # might not actually be used in all examples where it's included.
  config.after do
    if self.class.include?(Capybara::DSL)
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end

  config.before do
    if self.class.include?(Capybara::DSL)
      example = fetch_current_example.call(self)
      Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
      Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
    end
  end
end

Capybara.app = Middleman::Application.server.inst do
  set :root, File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  set :environment, :development
  set :show_exceptions, false
end

# Register Headless Chrome for Selenium
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new app, browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
end

Capybara.javascript_driver = :chrome
