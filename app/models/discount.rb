# Represents discount logic for a given item code.
# As implemented, only 2 types of discount logic are available: 
# percentage or incremental_volume
# if percentage:
# 		we expect to have a min_quantity and a discount_percentage
# if incremental_volume:
# 		we expect to have a increment_step, discount_per_step, and max_percentage_discount
# 
#   id (integer, primary key): Unique identifier for the inventory item.
# 	item_code (string, unique, not null)
#   discount_type (string, not null)
#   min_quantity (integer, optional)
#   discount_percentage (float, optional)
#   increment_step (integer, optional)
#   discount_per_step (float, optional)
#   max_percentage_discount (float, optional)
#   created_at (datetime, not null)
#   updated_at (datetime, not null)
class Discount < ApplicationRecord
	# item_code must be present
	validates :item_code, presence: true

	def self.find_by_code(item_code:)
		Discount.where(item_code:).first
	end

	def to_s
		if discount_type == "percentage"
			"#{discount_percentage}% off if you buy #{min_quantity} or more"
		elsif discount_type == "incremental_volume"
			"Increases by #{discount_per_step}% for every #{increment_step} items bought. Caps at #{max_percentage_discount}"
		end

		"No discount available"
	end

	# @param price [Float]
	# @param item_code [String]
	# @param num_items [Integer] 
	# @return total_price [Float] Total price of items with discount applied
	def discounted_total_for_items(price:, item_code:, num_items:)
		subtotal = num_items * price
		return subtotal if self.item_code != item_code

	    discount_to_apply = calculate_discount(num_items)
	    subtotal - (subtotal * (discount_to_apply))
  	end

  	# TODO Future Iteration: Updating discount percentages can be done here. We can create an API method that calls this method with the right parameters. 
  	def update_discount(item_code:, discount_type:, min_quantity: nil, discount_percentage: nil, increment_step: nil, discount_per_step: nil, max_percentage_discount: nil); end

  	private

  	def calculate_discount(num_items)
		if discount_type == "percentage" && num_items >= min_quantity
			return discount_percentage/100.0

		elsif discount_type == "incremental_volume"
			# all we need to do is get the highest divisor and multiply by discount
			tier_percentage = (num_items / increment_step) * discount_per_step

			percentage = [tier_percentage, max_percentage_discount].min
			return percentage/100.0
		end

		0.0
  	end

end
