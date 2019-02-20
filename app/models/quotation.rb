#
class Quotation < ApplicationRecord
  #
  enum status: %i[step1 step2]
  #
  attr_accessor :expected_asap
  #
  has_many :trucks
  has_many :truck_quotation_products, through: :trucks
  has_many :quotation_products, dependent: :destroy
  accepts_nested_attributes_for :quotation_products,
                                allow_destroy: true

  validates :customer_name, presence: true
  validates :address,       presence: true

  validates :email, presence: true
  validates :email,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            if: proc { |o| o.email.present? }

  validates :phone,
            presence: true,
            unless: proc { |o| o.cellphone.present? }

  validates :cellphone,
            presence: true,
            unless: proc { |o| o.phone.present? }

  def qp2accommodate
    quotation_products.reload
    quotation_products.select  { |x| x.pending.positive? }
                      .sort_by { |x| -x.pending }
  end

  after_create :accommodate_products
  #
  def accommodate_products
    qp = qp2accommodate
    while qp.any?
      distribute_products
      qp = qp2accommodate
    end
  end

  def distribute_products
    qp2accommodate.each do |o|
      t = o.truck_to_fit || trucks.build
      t.truck_quotation_products
       .build quotation_product: o,
              quantity: o.fittable_quantity

      t.save
    end
  end
end
