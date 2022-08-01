load File::expand_path('./page.rb', __dir__)

module MiddlemanSpaceHelpers
  include MiddlemanPageHelpers # for locale_page method

  def is_category_page?
    category = current_page.metadata[:locals][:category]
    return true if category && category[:id] && category[:id].downcase != 'all'

    false
  end
end