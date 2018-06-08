# frozen_string_literal: true
#
Ransack.configure do |config|
  config.add_predicate 'icont',
                       arel_predicate: 'matches',
                       formatter: proc { |s| "%#{::I18n.transliterate(s)}%" },
                       validator: proc { |s| s.present? },
                       compounds: true,
                       type: :string

  config.add_predicate 'date_gteq',
                       arel_predicate: 'gt',
                       formatter: proc { |v| v.to_date.beginning_of_day },
                       validator: proc { |v| v.present? },
                       type: :string

  config.add_predicate 'date_lteq',
                       arel_predicate: 'lt',
                       formatter: proc { |v| v.to_date.end_of_day },
                       validator: proc { |v| v.present? },
                       type: :string
end
