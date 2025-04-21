# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

initial_inventory = [
	{code: "MUG", name: "Reedsy Mug", price: 6.00, description: nil},
	{code: "TSHIRT", name: "Reedsy T-shirt", price: 15.00, description: nil},
	{code: "HOODIE", name: "Reedsy Hoodie", price: 20.00, description: nil},
]

initial_inventory.each do |attrs|
	Inventory.create(attrs)
end

# T-shirt discount
Discount.create!(
  item_code: 'TSHIRT',
  discount_type: 'percentage',
  min_quantity: 3,
  discount_percentage: 30
)

# MUG incremental volume discount
Discount.create!(
  item_code: 'MUG',
  discount_type: 'incremental_volume',
  increment_step: 10,
  discount_per_step: 2,
  max_percentage_discount: 30
)
