require 'cgi'

module CapybaraLandingPagesHelpers
  def get_landing_pages(locale_obj = Capybara.app.default_locale_obj)
    collection = Capybara.app.data['landing-pages'].pages
    collection = collection.map{ |tuple| tuple[1] } # contentful passes ["id", { ... }]
    collection = collection.map do |model|
      model = Capybara.app.localize_entry(model, locale_obj[:lang], Capybara.app.default_locale_obj[:lang])
      model = OpenStruct.new(model)

      model[:url] = Capybara.app.landing_page_url(model, locale_id: locale_obj[:id])
      model[:path] = Capybara.app.landing_page_path(model, locale_id: locale_obj[:id])

      # the browser will do this when it parses `&amp; => &`
      model[:page_title] = model[:page_title] && CGI::unescapeHTML(model[:page_title])
      model[:page_description] = model[:page_description] && CGI::unescapeHTML(model[:page_description])

      # mimic `layouts/partials/meta` which strips quotes
      model[:page_title] = model[:page_title] && BasicHelper.replace_quotes(model[:page_title])
      model[:page_description] = model[:page_description]&& BasicHelper.replace_quotes(model[:page_description])
      model
    end

    return collection
  end
end
