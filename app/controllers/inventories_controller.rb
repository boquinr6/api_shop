class InventoriesController < ApplicationController


	def index
		inventories = Inventory.all
		inventories = Inventory.all.map do |item|
      {
        name: item.name,
        price: format("$%.2f", item.price)
      }
    end

	    response_data = {
	      message: "Welcome to Reedsy Merchandise! Here are the items for sale:",
	      items: inventories
	    }

	    render json: response_data
	end

	def show

	end

	def update

	end

	
end
