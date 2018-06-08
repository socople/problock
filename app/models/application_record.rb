#
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def number?(string)
    return true if Float(string)
  rescue
    false
  end

  def id_from_string(klass, string)
    object = klass.where(klass.acts_as_label => string.to_s.strip).first
    write_attribute([klass.to_s.underscore, :id].join('_'), object.try(:id))
  rescue
    nil
  end

  def clear_errors!(options = {})
    clear_errors_except!(options[:except]) if options.key?(:except)
    clear_errors_only!(options[:only])     if options.key?(:only)
  end

  def clear_errors_except!(fields)
    errors.each { |key, _| errors.delete(key) unless fields.include?(key) }
  end

  def clear_errors_only!(fields)
    errors.each { |key, _| errors.delete(key) if fields.include?(key) }
  end

  def record_status
    return 'OK' unless errors.any?
    errors.full_messages.to_sentence
  end

  def save_permitted(permits)
    valid?
    clear_errors!(except: permits)
    save(validate: false) if errors.empty?
  end
end
