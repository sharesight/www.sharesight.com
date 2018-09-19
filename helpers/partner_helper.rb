module PartnerHelper
  def self.is_valid_partner?(model)
    return !!(
      model && !model[:name].blank? && !model[:url_slug].blank?
    ) rescue false
  end

  def self.is_valid_category?(model)
    return !!(
      model && !model[:name].blank? && !model[:url_slug].blank?
    ) rescue false
  end

  def self.sort_partners(a, b)
    a_priority = a[:priority].is_a?(Numeric) && a[:priority] || 0 # can be invalid...
    b_priority = b[:priority].is_a?(Numeric) && b[:priority] || 0 # can be invalid...
    return (a[:name] || '')&.strip&.downcase <=> (b[:name] || '')&.strip&.downcase if b_priority == a_priority
    return b_priority <=> a_priority
  end
end
