module MiddlemanLocaleHelpers
  # Locale Helpers
  def default_locale_id
    return config[:default_locale_id] # set in config.rb
  end

  def default_locale_obj
    return @default_locale_obj if !@default_locale_obj.nil?

    @default_locale_obj = get_locale_obj(default_locale_id)
    return @default_locale_obj
  end

  def current_locale_id
    locale_id = default_locale_id # default to the default id
    locale_id = current_path_array[0] if is_valid_locale_id?(current_path_array[0])

    return locale_id&.downcase
  end

  def current_locale_obj
    return get_locale_obj(current_locale_id)
  end

  def is_current_locale_id?(locale_id)
    locale_id = locale_id&.downcase
    return current_locale_id == locale_id
  end

  def get_locale_obj(locale_id = current_locale_id )
    locale_id = locale_id&.downcase

    locale_obj = data.locales.find { |x| x[:id] == locale_id }
    raise Exception.new("Missing locale data for #{locale_id}.") if locale_obj.nil? || locale_obj[:id].nil?
    return locale_obj || {} # default to an empty hash
  end

  def is_valid_locale_id?(locale_id)
    return !!data.locales.find { |x| x[:id]&.downcase == locale_id&.downcase }
  end

  def locale_cert_type(locale_obj = current_locale_obj)
    get_locale_obj(locale_obj[:id])&.cert_type&.to_s || 'stock'
  end

  def locale_plans(locale_id = current_locale_id)
    global = data.plans[default_locale_id]
    locale = data.plans[locale_id]

    # For each global plan, merge the locale plan ontop of it.
    # Global = defaults, locale = overrides!
    return locale.map{ |plan|
      global.find{ |p|
        p[:label] == plan[:label]
      }.deep_merge(plan)
    }
  end
end
