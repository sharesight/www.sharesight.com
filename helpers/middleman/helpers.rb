# frozen_string_literal: true

require 'ostruct'

# Use `load` to hot-reload these when they change.
# NOTE: It appears if you use `require_relative` it does not hot-reload them…
load File.expand_path('../basic_helper.rb', __dir__)
load File.expand_path('./blog.rb', __dir__)
load File.expand_path('./landing-pages.rb', __dir__)
load File.expand_path('./locale.rb', __dir__)
load File.expand_path('./menu.rb', __dir__)
load File.expand_path('./page.rb', __dir__)
load File.expand_path('./partners.rb', __dir__)
load File.expand_path('./space.rb', __dir__)
load File.expand_path('./url.rb', __dir__)

module MiddlemanHelpers
  include ::MiddlemanBlogHelpers
  include ::MiddlemanLandingPagesHelpers
  include ::MiddlemanLocaleHelpers
  include ::MiddlemanMenuHelpers
  include ::MiddlemanPageHelpers
  include ::MiddlemanPartnersHelpers
  include ::MiddlemanSpaceHelpers
  include ::MiddlemanUrlHelpers
end
