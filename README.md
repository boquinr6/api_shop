### Instructions

Before starting, please ensure you have Ruby (3.3.8) and postgresql installed. 

1. Clone the repository...
2. Install dependencies (`bundle install`).
3. Set up local DB:
- Run `rake db:create`
(this currently assumes a username of `postgres` and a blank password. Please update username and password if this command fails, i.e. in `.env`)
- Run `rails db:migrate`
- Run `rails db:seed`


To run specs:
1. Set up test DB:
- Run `rails db:create RAILS_ENV=test`
(this currently assumes a username of `postgres` and a blank password. Please update username and password if this command fails, i.e. in `.env`)
- Run `rails db:migrate RAILS_ENV=test`
2. Run `bundle exec rspec`

### Solution Design:
Database Options: 
1. Relational Database
2. Document Database

## Database Tables
Inventory
- Code, text (or uuid?), not-null
- Name, text, nullable
- Price, float, not-null
- Description, text, nullable


# Unnecessary tables for this project but could be useful
Users
- user_id, uuid, not-null
- user_email, text, not-null
- cart, text[] # an array of items that user has in their cart
- history, text[] # array of items that user has purchased 

Discounts
- inventory_code, text, not-null # this will be the way to join data between this table and Inventory
- 

## API Design:

# Question 1
Implement an API endpoint that allows listing the existing items in the store, as well as their attributes.

- GET
Status: 200, returns array of hashes
Example return:
[
{
code: t shirt
name: Reedsy t-shirt
price: 
discount_information: (for example, 30% off when buying 3 or more)
}, ....]

# Question 2
Implement an API endpoint that allows updating the price of a given product.

- POST or PATCH or PUT ? 
Parameters: text (Code of product), float (new price of product)
Status: 400 if bad param
Status: 200, returns code of product with new price (optionally maybe old price, as well?)

# Question 3
Implement an API endpoint that allows one to check the price of a given list of items.

- GET
Parameters: text[], list of items
Status: 400 if bad param
Status: 200, returns float price
- POST
put tally of items in JSON body - this seems unusual for an API call that isnt going to actually update the data model...but given that we don't have a limit for the items, this seems potentially better than a list of items.



## Discount design options: 
(1) having the discount logic live as a column in the Inventory table in the database (we'd have to read and interpret the discount data from the db, and this wouldn't be very flexible to update)
(2) having the discount logic live directly in the controller/model. This would be just a bunch of conditionals. Easy and straightforward to calculate but also might not be super flexible.
(3) Having the discount logic live in a json or yaml configuration. I like this option the most I think - we would load in each item's discount logic and calculate...we'd need to make some sort of json interpreter so it could be harder to code than (2), but it would be much more flexible to update the discount logic.
(4) Maybe making some sort of DiscountCalculator class that handles all the conditional logic - this would be an extension of 2, but it would be more of a service class to the controller. For this project, this might be too complicated. 

We will first try the (3) approach. 



## Other considerations: 
# Performance
- if we (1) get a large number of users running these API routes
If we were to actually create an application here, we would consider hosting this application in multiple web servers. We could add a load balancer to direct users to the right servers at scale.
- (2) get a query from a user asking what the total price is of a large number of items
Our APIs will scale in terms of performance with regard to size of the query from users. i.e. if the user asks for the price of n items, the time performance will be O(n). We will only need to read the inventory table a maximum of m times, where m is the size of the table. We can cache the results of reading the table, which will take O(m) memory but will save us table lookup time. 



I noticed the project didn't mention unit testing or integration testing. I plan to create rspec tests for the controller and any specific modules. Should I plan to create any kind of integration tests? For this, it might be easier to write out a "plan" for integration testing. 
How might we think about the users of this application? Can they be admins and buyers? User authentication is out of scope, but I wonder if it makes sense to code the part of the project that allows us to verify if a price of an inventory object can be updated...maybe checking for the presence of a token or anything like that? 




### How I worked on this project - Journal
1. Ran `rails new . --api --database=postgresql --skip-git` to set up a rails app and manually updated ruby version/gems
2. Focused on DB first. Used another rails helper to handle creating the migration file. Ran: 
``` 
rails generate model Inventory code:string:uniq:index name:string price:float description:text
```
Tested initializing a rails db and migrating and seeding to actually create and populate this table. In my company, we automatically generate migration files using rails or rake, but we edit the migration files directly to decide whether or not we should have an index, etc. 
3. Focused on adding read/write methods to model(s). At this point, i only have Inventory as my table, but considering whether or not i should create a Discount table instead of the yaml/json approach i considered earlier. I can then create an API that allows user to update discount logic.
4. Next, I created a controller using `rails generate controller Inventories` ...I thought about what the API endpoint should look like...thinking about 
- /inventory/all              (put this in a namespace)
- /inventories                (this as a url doesnt make sense to me)
- /inventory/id/update?price=[]
-/inventory/total?items=[]

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



### Problem from Reedsy:

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