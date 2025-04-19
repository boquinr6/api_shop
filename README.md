
Solution Design:
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

- POST or PATCH
Parameters: text (Code of product), float (new price of product)
Status: 400 if bad param
Status: 200, returns code of product with new price (optionally maybe old price, as well?)

# Question 3
Implement an API endpoint that allows one to check the price of a given list of items.

- GET
Parameters: text[], list of items
Status: 400 if bad param
Status: 200, returns float price

## Discount design options: 
(1) having the discount logic live as a column in the Inventory table in the database (we'd have to read and interpret the discount data from the db, and this wouldn't be very flexible to update)
(2) having the discount logic live directly in the controller/model. This would be just a bunch of conditionals. Easy and straightforward to calculate but also might not be super flexible.
(3) Having the discount logic live in a json or yaml configuration. I like this option the most I think - we would load in each item's discount logic and calculate...we'd need to make some sort of json interpreter so it could be harder to code than (2), but it would be much more flexible to update the discount logic.
(4) Maybe making some sort of DiscountCalculator class that handles all the conditional logic - this would be an extension of 2, but it would be more of a service class to the controller. For this project, this might be too complicated. 

We will first try the (3) approach. 



### Other considerations: 
# Performance
- if we (1) get a large number of users running these API routes
If we were to actually create an application here, we would consider hosting this application in multiple web servers. We could add a load balancer to direct users to the right servers at scale.
- (2) get a query from a user asking what the total price is of a large number of items
Our APIs will scale in terms of performance with regard to size of the query from users. i.e. if the user asks for the price of n items, the time performance will be O(n). We will only need to read the inventory table a maximum of m times, where m is the size of the table. We can cache the results of reading the table, which will take O(m) memory but will save us table lookup time. 



I noticed the project didn't mention unit testing or integration testing. I plan to create rspec tests for the controller and any specific modules. Should I plan to create any kind of integration tests? For this, it might be easier to write out a "plan" for integration testing. 
How might we think about the users of this application? Can they be admins and buyers? User authentication is out of scope, but I wonder if it makes sense to code the part of the project that allows us to verify if a price of an inventory object can be updated...maybe checking for the presence of a token or anything like that? 





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