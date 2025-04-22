class InventoriesController < ApplicationController


	def index
		all_items = Inventory.all.map do |item|
			discount = Discount.find_by_code(item_code: item.code)

			item_data = {
		        name: item.name,
		        price: format("$%.2f", item.price),
		        discount_information: discount&.to_s
		    }

		    end

	    response_data = {
	      message: "Welcome to Reedsy Merchandise! Here are the items for sale:",
	      items: all_items
	    }

	    render json: response_data
	end

	def total
		begin
			items = parse_list_of_items
			t = 0
			pp items
			pp "test"
			items.each do |item_code, num_items| 
				inventory = Inventory.find_by_code(item_code: item_code)
				discount = Discount.find_by_code(item_code: item_code)

				t += discount&.discounted_total_for_items(
					price: inventory.price,
					item_code: item_code,
					num_items: num_items
					) || (inventory.price * num_items)
			end

			response_data = {
		      message: "Here is the total price (including discounts) for #{items}:",
		      total_price: "$#{format("%.2f", t)}"
		    }

		    render json: response_data

		rescue ArgumentError => e
			render json: { error: e.message }, status: :bad_request

		end

	end

	def update_price
		begin
			inventory = Inventory.find(params[:id])
			inventory.update_price(params[:price])

	      	render json: { message: "Price updated successfully for #{inventory.name}", item: inventory }, status: :ok

		rescue 
			render json: { errors: inventory.errors.full_messages }, status: :unprocessable_entity


		end

	end

	private

	def parse_list_of_items
		return {} if !validate_list_of_items

		item_counts = {}

		# convert list of quantities and item codes to a hash of item => quantity
		params["items"].split(",").each_slice(2) do |num_items, item_code|
			quantity = Integer(num_items.strip)
			item_code = item_code.strip.upcase
			item_counts[item_code] = quantity
		end

		item_counts
	end

	def validate_list_of_items
		raise ArgumentError.new("Missing 'items' parameter") unless params["items"].present?

		raise ArgumentError.new("must be in pairs of Integer,item_code separated by comma e.g. 3,MUG, 2,TSHIRT...") if params["items"].split(",").size % 2 != 0

		item_counts = {}
		begin
			params["items"].split(",").each_slice(2) do |num_items, item_code|
			quantity = Integer(num_items.strip)
			item_code = item_code.strip.upcase
			item_counts[item_code] = quantity
		end
		rescue ArgumentError
			raise ArgumentError.new("must be in pairs of Integer,item_code separated by comma e.g. 3, MUG, 2, TSHIRT...") 
		end
	end

	
end
