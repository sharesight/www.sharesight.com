require 'ostruct'
load File::expand_path('../basic_helper.rb', __dir__)

# Load these as they're prone to change.
load File::expand_path('./blog.rb', __dir__)
load File::expand_path('./landing-pages.rb', __dir__)
load File::expand_path('./locale.rb', __dir__)
load File::expand_path('./page.rb', __dir__)
load File::expand_path('./partners.rb', __dir__)
load File::expand_path('./space.rb', __dir__)
load File::expand_path('./url.rb', __dir__)

module MiddlemanHelpers
  include ::MiddlemanBlogHelpers
  include ::MiddlemanLandingPagesHelpers
  include ::MiddlemanLocaleHelpers
  include ::MiddlemanPageHelpers
  include ::MiddlemanPartnersHelpers
  include ::MiddlemanSpaceHelpers
  include ::MiddlemanUrlHelpers
end
