class CreateDiscounts < ActiveRecord::Migration[7.2]
  def change
    create_table :discounts do |t|
      t.string :item_code, :null => false
      t.string :discount_type, :null => false
      t.integer :min_quantity
      t.float :discount_percentage
      t.integer :increment_step
      t.float :discount_per_step
      t.float :max_percentage_discount

      t.timestamps
    end
    add_index :discounts, :item_code
  end
end
