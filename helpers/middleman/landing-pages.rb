require 'ostruct'

module MiddlemanLandingPagesHelpers
  def landing_page_url(landing_page, locale_id: default_locale_id)
    return localize_url(landing_page_slug(landing_page), locale_id: locale_id)
  end

  def landing_page_path(landing_page, locale_id: default_locale_id)
    return localize_path(landing_page_slug(landing_page), locale_id: locale_id)
  end

  def landing_page_slug(landing_page)
    landing_page[:url_slug]
  end

  def landing_page_title(landing_page, locale_obj: default_locale_obj)
    "#{landing_page[:page_title]} | #{locale_obj[:append_title]}"
  end

  def landing_pages_collection(locale_obj: default_locale_obj, app_data: data)
    lang = locale_obj[:lang]

    @landing_pages_collection ||= {}
    @landing_pages_collection[lang] ||= app_data['landing-pages'].pages.map do |tuple|
      model = tuple[1] # contentful passes ["id", { ... }]
      localized_model = localize_entry(model, lang, default_locale_obj[:lang])
      localized_model[:title] = landing_page_title(localized_model, locale_obj: locale_obj)
      localized_model[:description] = localized_model[:page_description]

      localized_model
    end.reject{ |model| model[:url_slug].blank? }
  end
end
