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

  def landing_pages_collection(lang = default_locale_obj[:lang])
    return data['landing-pages'].pages
      .map{ |tuple| tuple[1] }
      .map{ |model| localize_entry(model, lang, default_locale_obj[:lang]) }
      .select{ |model| !model[:url_slug].blank? }
  end
end
