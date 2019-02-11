class Quotation < ApplicationRecord
  #
  attr_accessor :expected_asap
  #
  has_many :quotation_products
  accepts_nested_attributes_for :quotation_products,
                                allow_destroy: true
end
