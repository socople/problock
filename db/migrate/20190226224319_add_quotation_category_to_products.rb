class AddQuotationCategoryToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :quotation_category, foreign_key: true
  end
end
