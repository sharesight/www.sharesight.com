# frozen_string_literal: true

require 'cgi'

module CapybaraPartnersHelpers
  def get_partners_partners(locale_obj = Capybara.app.default_locale_obj)
    partners = Capybara.app.data.partners.partners.map { |tuple| tuple[1] }
    partners.map do |partner|
      partner = Capybara.app.localize_entry(partner, locale_obj[:lang], Capybara.app.default_locale_obj[:lang])
      partner = OpenStruct.new(partner) # hash does not like being mutable

      partner[:url] = Capybara.app.partner_url(partner, locale_id: locale_obj[:id])
      partner[:path] = Capybara.app.partner_path(partner, locale_id: locale_obj[:id])

      # The browser will do this when it parses `&amp; => &`
      partner[:name] = partner[:name] && CGI.unescapeHTML(partner[:name])
      partner[:short_description] = partner[:short_description] && CGI.unescapeHTML(partner[:short_description])

      # Mimic layouts/partials/head
      partner[:page_title] = "#{BasicHelper.replace_quotes(partner[:name])} | #{locale_obj[:append_title]} Partner"
      partner[:description] = BasicHelper.replace_quotes(partner[:short_description])
      partner
    end
  end

  def get_partners_categories(locale_obj = Capybara.app.default_locale_obj, check_length: true, all: false)
    categories = Capybara.app.data.partners.categories.map { |tuple| tuple[1] }
    categories = categories.select { |category| category && category[:name] } # only categories with a truthy name
    categories = categories.map do |category|
      Capybara.app.localize_entry(category, locale_obj[:lang], Capybara.app.default_locale_obj[:lang])
    end
    categories << OpenStruct.new({ id: 'all', name: 'All', url_slug: 'all' }) if all == true

    partners = get_partners_partners(locale_obj)

    # remap to new categories
    categories = categories.map do |category|
      category = OpenStruct.new(category) # category object does not like being mutable
      category[:title] = category[:id] == 'all' ? 'Partners' : category[:name]
      category[:title] = CGI.unescapeHTML(category[:title])

      category[:page_title] = "#{category[:name]} Partners | #{locale_obj[:append_title]}"
      category[:page_title] = locale_page('partners/all', locale_obj)[:page_title] if category[:id] == 'all'
      category[:page_title] = CGI.unescapeHTML(category[:page_title])
      category[:page_title] = BasicHelper.replace_quotes(category[:page_title])

      category[:social_title] = "#{category[:name]} Partners | #{default_locale_obj[:append_title]}"
      category[:social_title] = base_locale_page('partners/all')[:page_title] if category[:id] == 'all'
      category[:social_title] = CGI.unescapeHTML(category[:social_title])
      category[:social_title] = BasicHelper.replace_quotes(category[:social_title])

      category[:description] = category[:description] || locale_page('partners', locale_obj)[:description]
      if category[:id] == 'all'
        category[:description] =
          category[:description] || locale_page('partners/all', locale_obj)[:description]
      end
      category[:social_description] = category[:description] || base_locale_page('partners')[:description]
      if category[:id] == 'all'
        category[:social_description] =
          category[:description] || base_locale_page('partners/all')[:description]
      end

      category[:path] = localize_path("partners/#{category[:url_slug]}", locale_id: locale_obj[:id])
      category[:url] = localize_url(category[:path], locale_id: locale_obj[:id])

      category[:partners] = if category[:id] != 'all'
                              partners.select do |partner|
                                partner.categories.select do |partner_category|
                                  partner_category[:id] == category[:id]
                                end.length >= 1
                              rescue StandardError
                                false
                              end
                            else
                              partners
                            end

      category # return to map
    end

    return categories unless check_length

    # only take categories with partners
    categories.select { |category| category.partners&.length >= 1 }
  end
end
