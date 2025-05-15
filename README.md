Welcome to Raul Boquin's Reedsy Backend Challenge.
# Instructions

Before starting, please ensure you have Ruby (3.3.8) and postgresql (17.4) installed. This was developed and tested on a Windows machine so some commands might be different!

1. Clone the repository and cd into it...
2. Install dependencies (`bundle install`).
3. Set up local DB:
- Create a .env file with postgresql username and password and put it in the root of directory: 
```
PG_USERNAME=your_username
PG_PASSWORD=your_password
```
Alternatively, you can alter `databse.yml` directly and hardocode username and password.
- Run `rake db:create`
(don't forget the `.env` file with postgres username and password. Please update values accordingly. I used the default user `postgres` and the password that I set when downloading `psql`)

- Run `rails db:migrate`
- Run `rails db:seed`

4. Run `rails server` or `rails server -e development`. You're now ready to test the APIs!
5. Open a second terminal and cd into the repo.
6. In your second terminal, run the curl commands from the API Design section below to test the application:
API 1: `curl -v 'http://localhost:3000/inventory/all' -o output.txt`
API 2: I actually was having trouble using curl here for a PUT request. after some research, it may be a windows powershell issue. The equivalent windows command is: 
`Invoke-WebRequest -Uri 'http://localhost:3000/inventory/HOODIE/update_price?price=1.23' -Method Put`
The equivalent curl command would be: 
`curl -X PUT 'http://localhost:3000/inventory/HOODIE/update_price?price=1.23'` 

API 3: `curl 'http://localhost:3000/inventory/total?items=1,MUG,3,TSHIRT'`

7. Please read more about the API Design below.
8. To run test suite, see instructions below. 
9. I created a section in this readme called "How I worked on this project - Journal" - this is optional to read, but meant to be read to understand how i thought about this problem and the issues i ran into along the way. I'm happy to discuss them live and discuss what the biggest decisions i had to make and where i had the most successes and frustrations! Thank you for your time in reading through the application, and thank you for the opportunity. 

## API Design

# Question 1
Implement an API endpoint that allows listing the existing items in the store, as well as their attributes.

- GET 
Status: 200, returns array of hashes
Route: 
  `get "inventory/all" => "inventories#index"`
This was just a simple GET...decided to only show the name, price, and discount information for each item.

To test:
`curl -v 'http://localhost:3000/inventory/all' -o output.txt`

Example return:
```
{"message":"Welcome to Reedsy Merchandise! Here are the items for sale:","items":[{"name":"Reedsy T-shirt","price":"$15.00","discount_information":"30.0% off if you buy 3 or more"},{"name":"Reedsy Mug","price":"$6.00","discount_information":"Increases by 2.0% for every 10 items bought. Caps at 30.0"},{"name":"Reedsy Hoodie","price":"$20.00","discount_information":null}]}
```

# Question 2
Implement an API endpoint that allows updating the price of a given product.

- PUT 
Route: `inventory/:code/update_price?price=x`
Parameters: float (new price of product)
Status: 404 if record :code not found in Inventory
Status: 400 if price is not integer, bad param
Status: 200, returns code of product with new price

To test: 
I actually was having trouble using curl here for a PUT request. after some research, it may be a windows powershell issue. The equivalent command is: 
`Invoke-WebRequest -Uri 'http://localhost:3000/inventory/HOODIE/update_price?price=1.23' -Method Put`
The equivalent curl command would be: 
`curl -X PUT 'http://localhost:3000/inventory/HOODIE/update_price?price=1.23'` 
But I haven't tested the curl command! 
To test that this was running correctly, I reran `curl -v 'http://localhost:3000/inventory/all'` and verified that HOODIE updated its price correctly!

# Question 3
Implement an API endpoint that allows one to check the price of a given list of items.

- GET
Parameters: text[], list of items
Status: 400 if bad param of items
Status: 404 if item record not found in Inventory
Status: 200, returns float price
- I originally considered a POST request ; put tally of items in JSON body - this seems unusual for an API call that isnt going to actually update the data model...but given that we don't have a limit for the items, this seems potentially better than a list of items.

I decided to go with the GET request given the problem specifically states a list of items, but I did restrict the input to be a specific type of list. Here's a sample curl to explain:

`curl 'http://localhost:3000/inventory/total?items=1,MUG,3,TSHIRT'`
We restrict the list of items to be Integer,item_code pairs. If we don't get an input in this format, we return a 400 invalid client-side parameter status. We return

```
{"message":"Here is the total price (including discounts) for {\"MUG\"=\u003e1,
                    \"TSHIRT\"=\u003e3}:","total_price":"$37.50"}
```

# Question 4: Discounts
- Please see `discount.rb` model and `InventoriesController#total` to see how discount is applied. 



## To run specs:
1. Set up test DB:
- Run `rails db:create RAILS_ENV=test`
(this currently assumes a username of `postgres` and a blank password. Please update username and password if this command fails, i.e. in `.env`)
- Run `rails db:migrate RAILS_ENV=test`
2. Run `bundle exec rspec -fd`
3. Please make sure you switch back your RAILS_ENV back to `development` when you're done testing! 

Output of specs: 
```
dev\reedsy> bundle exec rspec -fd

Discount
  #discounted_total_for_items
    when discount type is percentage
      applies a discount since the num_items is 3 or more
      when num_items is less than min_quantity
        does not apply discount
    when discount type is volume
      applies a 2% discount since num_items is between 10 and 20, inclusive
      when num_items is next increment
        applies a 4% discount since num_items is between 20 and 30

Inventory
  #update_price
    is expected to be truthy
    is expected to eq 456.123

Finished in 0.27692 seconds (files took 2.7 seconds to load)
6 examples, 0 failures
```

## What code to review: 
Much of the code in this repo is generated by the `rails new` command. Here the specific files I added/worked on: 
- .env    
- GEMFILE
- .gitignore
- app/
  - controllers/
    - inventories_controller.rb  
  - models/
    - discount.rb         
    - inventory.rb        
- config/
  - routes.rb 
  - database.yml            
- db/
  - migrate/ 
  - seeds.rb                
- spec/ 
  - models/
    - discount_spec.rb   
    - inventory_spec.rb  


# Solution Design (more of a notes document):
Database Options: 
1. Relational Database (psql)
2. Document Database - did not go with this

## Database Tables
Inventory
- Code, text (or uuid?), not-null
- Name, text, nullable
- Price, float, not-null
- Description, text, nullable

Discount
- item_code, text, not-null
- discount_type, text, not-null, percentage or incremental_volume
- minimum_quantity, integer, nullable
- discount_percentage, float, nullable
- increment_step, integer, nullable
- discount_per_step, float, nullable
- max_percentage_discount, float, nullable

### Unnecessary tables for this project but could be useful
Users
- user_id, uuid, not-null
- user_email, text, not-null
- cart, text[] # an array of items that user has in their cart
- history, text[] # array of items that user has purchased 


## Discount design options (historical): 
(1) having the discount logic live as a column in the Inventory table in the database (we'd have to read and interpret the discount data from the db, and this wouldn't be very flexible to update)
(2) having the discount logic live directly in the controller/model. This would be just a bunch of conditionals. Easy and straightforward to calculate but also might not be super flexible.
(3) Having the discount logic live in a json or yaml configuration. I like this option the most I think - we would load in each item's discount logic and calculate...we'd need to make some sort of json interpreter so it could be harder to code than (2), but it would be much more flexible to update the discount logic.
(4) Maybe making some sort of DiscountCalculator class that handles all the conditional logic - this would be an extension of 2, but it would be more of a service class to the controller. For this project, this might be too complicated. 

We will first try the (3) approach.
Edit: We ended up going with none of these, but maybe a variation of 3! After trying out (3), I realized it would actually be much easier to host this logic in its own table. So I created a Discount Model that calculates the total price of a given item and its quantity. 

## Other considerations: 
### Performance
- if we (1) get a large number of users running these API routes
If we were to actually create an application here, we would consider hosting this application in multiple web servers. We could add a load balancer to direct users to the right servers at scale.
- (2) get a query from a user asking what the total price is of a large number of items
Our APIs will scale in terms of performance with regard to size of the query from users. i.e. if the user asks for the price of n items, the time performance will be O(n). We will only need to read the inventory table a maximum of m times, where m is the size of the table. We can cache the results of reading the table, which will take O(m) memory but will save us table lookup time. 
Edit: thinking about this more, we would only need to read the Inventory table 1 time, cache the results, and it should take O(1) time to do cache lookups. 

### Testing
I noticed the project didn't mention unit testing or integration testing. I plan to create rspec tests for the controller and any specific modules. Should I plan to create any kind of integration tests? For this, it might be easier to write out a "plan" for integration testing. 
Edit: I ended up creating tests here for the models. I believe that almost all code should be thoroughly unit tested and pass a test suite before merging. If I had more time, I would've probably created a bit more here. 

## How I worked on this project - Journal
1. Ran `rails new . --api --database=postgresql --skip-git` to set up a rails app and manually updated ruby version/gems
2. Focused on DB first. Used another rails helper to handle creating the migration file. Ran: 
``` 
rails generate model Inventory code:string:uniq:index name:string price:float description:text
```
Tested initializing a rails db and migrating and seeding to actually create and populate this table. In my company, we automatically generate migration files using rails or rake, but we edit the migration files directly to decide whether or not we should have an index, etc. 

3. Focused on adding read/write methods to model(s). At this point, i only have Inventory as my table, but considering whether or not i should create a Discount table instead of the yaml/json approach i considered earlier. I can then create an API that allows user to update discount logic.

4. Next, I created a controller using `rails generate controller Inventories` ...I thought about what the API endpoint should look like...thinking about 
- /inventory/all              (put this in a namespace?)
- /inventories                (this as a url doesnt make sense to me)
- /inventory/id/update?price=[]
- /inventory/update?id=""&price=""
- /inventory/code/update?price=""
- /inventory/total?items=[]

I decided to follow the Rails Model-View-Controller here and go with inventory/ as the base for the APIs...I think this is clear and matches conventions. Cons may be: harder to extend if we want multiple controllers within an "inventory" namespace. 

5. Next, I had a huge problem testing these APIs that took up more time i'm a bit embarrased to admit. I never found a root cause but it looks like running my test suite i.e. `bundle exec rspec` rewrote my RAILS_ENV environment variable to `test` instead of `development`. This never happens when i develop using docker or in macos, and this was my first time developing locally on windows. Re-updating RAILS_ENV fixed this easily, but an interesting issue, and points to how nice it is to have docker or a VM handle all this stuff.

6. Next, I started thinking more about the discount design. There are 2 distinct discount types:
- a discount for buying X or more of the same item
- a volume discount that changes every 10 items
There are 2 ways we can design a table/model to store this discount information:
Method #1 - hardcode every discount as a row in DiscountTable
DiscountTable:
- id
- item_code, string, this is how we join discount info to item
- minimmum_item_count, integer, the min number to activate the discount
- maximum_item_count, integer, the max number to activate the discount, if nil, then anything greater than min item count activates the discount
- discount_percentage, float, the discount to apply

Example usage: 
```
Discount.create!(
  item_code: 'TSHIRT',
  discount_type: 'percentage',
  minimmum_item_count: 3,
  discount_percentage: 0.30
)

# For MUG volume discounts, we'll need multiple records
Discount.create!(
  item_code: 'MUG',
  discount_type: 'percentage', # Treating these as percentage discounts based on quantity
  minimmum_item_count: 10,
  maximum_item_count: 19,
  discount_percentage: 0.02
)

Discount.create!(
  item_code: 'MUG',
  discount_type: 'percentage',
  minimmum_item_count: 20,
  maximum_item_count: 29,
  discount_percentage: 0.04
)
...
# and so on
```
Cons: this would not be DRY and necessitate requiring a record in the DiscountTable for EVERY discount, even though there is a pattern for incrementing the discount by 2% every 10 items.

Method #2 - have two types of discounts in DiscountTable
DiscountTable:
- id
- item_code, string, this is how we join discount info to item
- discount_type, string, either percentage or volume
- minimum_item_count, integer, the min number to activate the discount
- discount_percentage, float, the discount to apply
- increment_step, integer, the amount of items that where the next tier of discount can be applied
- discount_per_step, integer, 
- maximum_num_items_for_discount, integer, if num of items is this or more, discount will be maximally incremented discount

Example Usage:
```
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
  discount_per_step: 0.02,
  maximum_num_items_for_discount: 150
)
```

Cons: a bit harder to code in that we have to fork the logic between percentage discounts and incremental_volume discounts. Also, for incremental volume discounts, we can only update the increment_step and the discount_per_step...if we wanted to update the discounts more precisely (let's say we wanted to give 5% off for buying between 20 and 30 items but kep everything else the same incrementing by 2%...we could not do this with Method #2)

 `rails generate model Discount item_code:string:index discount_type:string min_quantity:integer discount_percentage:float increment_step:integer discount_per_step:float maximum_num_items_for_discount:integer`

 In the end, I went with Method#2 for the discount logic!

 7. Next, I took a look at how i wanted to construct the API endpoint for getting a total price from a list of items. Originally, I was going to use a simple GET request with the param being a list of items e.g. `/inventory/total?list=MUG,MUG,MUG,HOODIE,HOODIE` --> this represents a request for the total price of 3 mugs and 2 hoodies. 
 But then I realized we don't have a limit here, and our URL length could get super unwieldy. So I started to think about what passing in a JSON tally of items and quantities e.g. 
 ```
 {
  "items": [
  {"code": "MUG", "quantity": "3"}
  ]
 }
 ```

 The latter seemed more like the correct solution, but even passing in a JSON blob like this to a GET request seemed like it would make the URL way too long and unwieldy. Yet another alternative i considered was making a POST request with this JSON in the body of the POST request. One con of a POST request is that GET requests are idempotent, and POST requests are generally used to change or update the data model. 

 For simplicity, I decided to do a GET request with a list of items and their quantity, since it more closely matched the problem statement...but in future iterations, i'd imagine industry-accepted patterns do this in a POST method or are calculating a running total in-memory.
 What I went with: 
 `?items=1,MUG,2,TSHIRT,3,HOODIE`

 8. One other bug that was hard to detect was my use of 
 `params["items"].split(",").each_slice(2).to_h` to convert my list of items to a tally of item code to num_items `{HOODIE: 1, TSHIRT: 1}`. I didn't realize that by doing this, i was overriding an item if there was one of the same quantity if the url looks like this: 
 `curl 'http://localhost:3000/inventory/total?items=1,MUG,3,TSHIRT,1,HOODIE'`
 To solve this, I updated my `parse_list_of_items` helper method to instead construct a hash instead of trying to use `to_h` directly:
 ```
    item_counts = {}

    # convert list of quantities and item codes to a hash of item => quantity
    params["items"].split(",").each_slice(2) do |num_items, item_code|
      quantity = Integer(num_items.strip)
      item_code = item_code.strip.upcase
      item_counts[item_code] = quantity
    end
```

9. Finally, I worked on the last piece of the problem prompt...allowing the user to update the price of an item via API. Initially, it made sense to me to have a URL like 
- /inventory/update_price?price=1.23&item=mug
or 
- /inventory/mug/update_price?price=1.23
But as i was researching this and remembered what we do at my current company, I know that it's best practice here to use the ActiveRecord numerical ID...it is immutable, has performant lookups, and is guaranteed to be unique compared to using item_code. We could argue that using item_code in the URL is more user-friendly, but an action like updating the price is more likely to be used by someone who knows the IDs of the records. So in the end, I went with this as the url:
- /inventory/:id/update_price?price=1.23
Edit: So I changed this again! Instead of using `:id` I decided to use `:code` to make the code less DRY. In the future, I would probably go back to using `:id` since that is more industry-accepted, but I went for ease for the user here. It's easier for the user to run an API `/inventory/MUG/update_price?price` , then to run `/inventory/1/update_price?price` because then i would be requiring the user to search for the ID of the item. 

10. Finishing up: In my last commit, I decided to refactor the controller a bit and did a couple of cleanup tasks that i thought about from the beginning of the project: (1) memoized calls to the DB for the #total method to minimize DB calls, (2) update my status rendering to render correct status codes for errors, like 404 for record not found or 400 for bad param, and (3) added some small helper methods to be more DRY. I added some specs for the Discount table. 

11. What would I do next: Since testing was not required for this project, I didn't write specs for inventories_controller...that would be the first task I do next if i were to pick this up for real. Also add more validations here, especially to the data models. I would also take out some of the logic from the controller and Discount model to make things more modular. I think we could actually extract some of the logic out of the discount model to its own service and maybe refactor #validate_list_of_items or put it in a shared module.


# Problem from Reedsy:

Reedsy would like to expand its business to include a merchandise store for our professionals. It will be comprised of 3 items:

Code         | Name                   |  Price
-------------------------------------------------
MUG          | Reedsy Mug             |   6.00
TSHIRT       | Reedsy T-shirt         |  15.00
HOODIE       | Reedsy Hoodie          |  20.00
We would like you to provide us with a small web application to help us manage this store.

Guidelines
Some important notes before diving into the specifics:

we expect this challenge to be done using Ruby on Rails;
any detail that is not specified throughout this assignment is for you to decide. Our questions and examples are agnostic on purpose, so as to not bias your toward a specific format. If you work at Reedsy you will make decisions and we want that to reflect here. This being said, if you spot anything that you really think should be detailed here, feel free to let us know;
the goal of this challenge is to see if you're able to write code that follows development best practices and is maintainable. It shouldn't be too complicated (you don't need to worry about authentication, for example) but it should be solid enough to ship to production;
regarding dependencies:
try to keep them to a minimum. It's OK to add a dependency that adds a localized and easy to understand functionality;
avoid dependencies that significantly break away from standard Rails or that have a big DSL to learn (e.g., Grape). It makes it much harder for us to evaluate the challenge if it deviates a lot from vanilla Rails. If in doubt, err on the side of using less dependencies or check with us if it's OK to use;
in terms of database any of SQLite, PostgreSQL or MySQL will be fine;
include also with your solution:
instructions on how to setup and run your application;
a description of the API endpoints with cURL examples.
Out of scope
Here's a non-exhaustive list of functionalities that you don't need to worry about in your solution:

UI - the application should be API only, so don't include any sort of front-end;
Swagger / Postman documentation or anything of that sort;
authentication / authorization;
filters / search / pagination;
asynchronous jobs.
How do I know when to stop adding more functionalities?
This challenge was designed to not take too much of your precious time. If it's taking you the whole day or more, maybe it's time to wrap up what you already have and ship it.

Question 1
Implement an API endpoint that allows listing the existing items in the store, as well as their attributes.

Question 2
Implement an API endpoint that allows updating the price of a given product.

Question 3
Implement an API endpoint that allows one to check the price of a given list of items.

Some examples on the values expected:

Items: 1 MUG, 1 TSHIRT, 1 HOODIE
Total: 41.00
Items: 2 MUG, 1 TSHIRT
Total: 27.00
Items: 3 MUG, 1 TSHIRT
Total: 33.00
Items: 2 MUG, 4 TSHIRT, 1 HOODIE
Total: 92.00

Question 4
We'd like to expand our store to provide some discounted prices in some situations.

30% discounts on all TSHIRT items when buying 3 or more.
Volume discount for MUG items:
2% discount for 10 to 19 items
4% discount for 20 to 29 items
6% discount for 30 to 39 items
... (and so forth with discounts increasing in steps of 2%)
30% discount for 150 or more items
Make the necessary changes to your code to allow these discounts to be in place and to be reflected in the existing endpoints. Also make your discounts flexible enough so that it's easy to change a discount's percentage (i.e., with minimal impact to the source code).

Here's how the above price examples would be updated with these discounts:

Items: 1 MUG, 1 TSHIRT, 1 HOODIE
Total: 41.00
Items: 9 MUG, 1 TSHIRT
Total: 69.00
Items: 10 MUG, 1 TSHIRT
Total: 73.80

Explanation:
  - Total without discount: 60.00 + 15.00 = 75.00
  - Discount: 1.20 (2% discount on MUG)
  - Total: 75.00 - 1.20 = 73.80
Items: 45 MUG, 3 TSHIRT
Total: 279.90

Explanation:
  - Total without discount: 270.00 + 45.00 = 315.00
  - Discount: 21.60 (8% discount on MUG) + 13.50 (30% discount on TSHIRT) = 35.10
  - Total: 315.00 - 35.10 = 279.90
Items: 200 MUG, 4 TSHIRT, 1 HOODIE
Total: 902.00

Explanation:
  - Total without discount: 1200.00 + 60.00 + 20.00 = 1280.00
  - Discount: 360.00 (30% discount on MUG) + 18.00 (30% discount on TSHIRT) = 378.00
  - Total: 1280.00 - 378.00 = 902.00