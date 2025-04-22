class InventoriesController < ApplicationController

	# GET /inventory/all
	def index
		all_items = Inventory.all.map do |item|
				discount = all_discounts[item.code]

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

	# GET /inventory/total?items=""
	# @raise ArgumentError, 400 if items param is incorrect format
	# @raise 404, if item not found
	def total
		begin
			items = parse_list_of_items
			running_total = 0

			items.each do |item_code, num_items| 
				inventory = find_inventory(item_code)
				return unless inventory
				discount = all_discounts[item_code]

				# if a discount exists, add the discounted total for the given items and price
				# => Otherwise, just multiply the price by the number of items
				running_total += discount&.discounted_total_for_items(
					price: inventory.price,
					item_code: item_code,
					num_items: num_items
					) || (inventory.price * num_items)
			end

			# TODO: items hash values are returning in unicode. Figure out how to fix this. 
			response_data = {
		      message: "Here is the total price (including discounts) for #{items}:",
		      total_price: "$#{format("%.2f", running_total)}"
		    }

		    render json: response_data

		rescue ArgumentError => e
			render json: { error: e.message }, status: :bad_request
		end

	end

	# PUT inventory/:code/update_price?price=""
	# @raise 400, if price param is invalid
	# @raise 404, if :code record is not found
	def update_price
		inventory = find_inventory(params[:code])

		return unless inventory

		begin
			inventory.update_price(params[:price])
			render json: { message: "Price updated successfully for #{inventory.name}", item: inventory }, status: :ok
		rescue ArgumentError => e
			render json: { error: e.message }, status: :bad_request
		end
	end

	private

	def find_inventory(item_code)
		inventory = all_inventory[item_code]

		if inventory.nil?
			render json: { error: "Item '#{item_code}' not found" }, status: :not_found
			nil
		else
			inventory
		end
	end

	# @param items, string expected: "Integer,item_code,Integer,item_code,Integer,item_code..."
	# @return Hash<String,Integer> {item_code => Integer, item_code => integer}
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

	# @raise ArgumentError if items parameter is missing or if list isnt formatted correctly in pairs
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
			raise ArgumentError.new("arg must be in pairs of Integer,item_code separated by comma e.g. 3,MUG,2, TSHIRT...") 
		end
	end

	# Memoize Inventory and Discounts to reduce calls to the DB especially for #total
	# Future improvement: instead of saving the entire Inventory/Discount table
	# => 				save just the given item codes, i.e. 
	# 					Inventory.where(item_codes: []).all
	def all_inventory
		@all_inventory ||= Inventory.all.index_by(&:code)
	end

	def all_discounts
		@all_discounts ||= Discount.all.index_by(&:item_code)
	end

	
end
