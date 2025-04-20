class Inventory < ApplicationRecord
	# ensure items in Inventory have unique codes
	validates :code, presence: true, uniqueness: true



	def self.get_all_data
		Inventory.all
	end

	def self.find_by_code(code)
		Inventory.where(code:).first
	end

	def update_price(new_price)
		begin

			update(price: Float(new_price))

		rescue 
			raise ArgumentError, "Price '#{new_price}' must be numerical"	 
		end
	end

end
