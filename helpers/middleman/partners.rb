require 'ostruct'
load File::expand_path('../partner_helper.rb', __dir__)

module MiddlemanPartnersHelpers
  def partner_url(partner, locale_id: default_locale_id)
    return localize_url(partner_slug(partner), locale_id: locale_id)
  end

  def partner_path(partner, locale_id: default_locale_id)
    return localize_path(partner_slug(partner), locale_id: locale_id)
  end

  def partner_slug(partner)
    "partners/#{partner[:url_slug]}"
  end

  def sort_categories(a, b)
    return -1000 if a[:id] == 'all'
    return 1000 if b[:id] == 'all'
    (a[:name] || '')&.strip&.downcase <=> (b[:name] || '')&.strip&.downcase
  end

  def partners_collection(lang = default_locale_obj[:lang])
    return data.partners.partners
      .map{ |tuple| tuple[1] }
      .map{ |model| localize_entry(model, lang, default_locale_obj[:lang]) }
      .select{ |model| PartnerHelper.is_valid_partner?(model) }
      .sort{ |a, b| PartnerHelper.sort_partners(a, b) }
  end

  def categories_collection(lang = default_locale_obj[:lang])
    return data.partners.categories
      .map{ |tuple| tuple[1] }
      .map{ |model| localize_entry(model, lang, default_locale_obj[:lang]) }
      .select{ |model| PartnerHelper.is_valid_category?(model) }
      .sort{ |a, b| sort_categories(a, b) }
  end

  # localize_value should always have a third argument: fallback_locale!
  def partners_categories(lang = default_locale_obj[:lang], withIndex: false)
    array = []
    collection = partners_collection(lang)
    categories = categories_collection(lang)

    if withIndex == true
      array.push({
        id: 'all',
        name: 'All',
        description: nil,
        _meta: nil,
        path: "partners/all",
        url_slug: "all",
        count: collection.length,
        set: collection
      })
    end

    collection = categories.each do |category|
      set = collection.select { |model|
        # models that have the category id
        model[:categories]&.find{ |model_category| model_category[:id].include?(category[:id]) }
      }

      array.push({
        id: category[:id],
        name: category[:name],
        description: category[:description],
        _meta: category[:_meta],
        path: "partners/#{category[:url_slug]}",
        url_slug: category[:url_slug],
        count: set.length,
        set: set
      })
    end

    # Stick the all category to the top.
    return array.sort{ |a, b| sort_categories(a, b) }
  end
end
