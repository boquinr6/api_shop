# Represents items for sale.
# 
#   id (integer, primary key): Unique identifier for the inventory item.
#   code (string, unique, not null): A short, unique code for the item (e.g., "MUG", "TSHIRT").
#   name (string, not null): The descriptive name of the inventory item (e.g., "Reedsy Mug").
#   price (float, not null): The selling price of the item.
#   description (text, optional): A longer description of the item.
#   created_at (datetime, not null): Timestamp when the item was added to the inventory.
#   updated_at (datetime, not null): Timestamp when the item was last updated.
#
class Inventory < ApplicationRecord
	# ensure items in Inventory have unique codes
	validates :code, presence: true, uniqueness: true


	def self.get_all_data
		Inventory.all
	end

	def self.find_by_code(item_code:)
		Inventory.where(code: item_code).first
	end

	def update_price(new_price)
		begin
			update(price: Float(new_price))

		rescue 
			raise ArgumentError, "Price '#{new_price}' must be numerical"	 
		end
	end

end
