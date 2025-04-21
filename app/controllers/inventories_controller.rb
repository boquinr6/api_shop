class InventoriesController < ApplicationController


	def index
		all_items = Inventory.all.map do |item|
			discount = Discount.find_by_code(item_code: item.code)

			item_data = {
		        name: item.name,
		        price: format("$%.2f", item.price)
		        discount_information: discount&.to_s
		    }

		    end

	    response_data = {
	      message: "Welcome to Reedsy Merchandise! Here are the items for sale:",
	      items: all_items
	    }

	    render json: response_data
	end

	def show

	end

	def update

	end

	
end
