Active Record is the ORM used in Rails. It is used to map objects to database collumns

## Naming
- tables are plural and come from class name which follow CamelCase
- collumnd are singular and are instance variables that follow 
(you can overide the table naming convention by defining the table name that should be used by adding the code `self.table_name = "<custom_table_name>"` in the class. Doing this affects the fixtures used for testing. See [here](https://guides.rubyonrails.org/active_record_basics.html#overriding-the-naming-conventions) for more details)
- foreign keys are named <singular_table_name>_id 


## Active Record Model Class
The first thing you need to do is have the class subclass from ApplicationRecord 

```ruby
class model < ApplicationRecord
end
```

(This is true in rails 5, where ApplicationRecord is a class that subclasses from ActiveRecord::Base. You can find the ApplicationRecord class in `/app/models/application_record.rb`. The reason for the change is that now all custom methods should be available to every active record class can be included in ApplicationRecord and inherited. Before in order to do this you would have had to use monkey patching to add the customization to ActiveRecord::Base. See [this](https://blog.bigbinary.com/2015/12/28/application-record-in-rails-5.html) article for an extended explanation)

While in a normal class defintion you need to specify attributes directly, ActiveRecord objects infer their attributes from the columns of the tables they are linked to. 
## Creating ActiveRecord Objects

ActiveRecord objects can be instantiated with either the `new` or `create` methods. The difference is that the `create` method will save the data to the database. If created with the `new` method the objects need to be saved to the database later with the `create` method. 

There are three ways that instance variables can be set for an ActiveRecord model. 
They can 1) be passed in as hash to `new`/`create`, 2) be set in a block that is passed in to the `new`/`create` methods, 3) be set manually after object instantiation. 

```ruby
#1 
user = User.new(first_name: "David", last_name: "Jones")

#2 
user = User.new do |usr|
  usr.first_name = "David"
  usr.last_name = "Jones"
end

#3
user = User.new
user.first_name = "David"
user.last_name = "Jones"
```

## Reading ActiveRecord Objects From The Database

1) To get all the objects of a table use the `all` class method. This returns an ActiveRecord::Relation object. The object has an instance variable `records` which is an array of the ActiveRecord model objects pulled from the database

```ruby
Users = User.all #ActiveRecord::Relation

# SQL: SELECT "users".* FROM "users"
```

2) To get the first object of that type use the `first` class method 

```ruby 
first_user = User.first

# SQL: SELECT  "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
```

There are many other methods available to create specific SQL queries. For complete details see [this page](https://guides.rubyonrails.org/active_record_querying.html). Some common methods are:
1) find
2) find_by
3) where 
4) take
5) order
6) not
7) or
8) select
9) distinct

## Updating Records
The way to update a record in the db is to retrieve it, update the instance variables, and then save the record to the db using the `save` method. 

```ruby
user = User.find_by(name: 'David')
user.name = "Jason"
user.save
```

You can also directly update specific attributes by calling the `update` method and passing in a hash with attributes as keys and the new values as values. 
```ruby
user = User.find_by(name: "David")
user.update(name: "Jason")
sql: UPDATE "user" SET "name" = "jason", "updated_at" = <current time> WHERE "user"."id" = <user's id>
```

Depending on the problem, this approach might need to be changed to update the records without retrieving them first from the db (2 steps vs. 1) . See [this](https://stackoverflow.com/questions/9865843/is-it-possible-to-alter-a-record-in-rails-without-first-reading-it) discussion for more details. For automatically saving attributes and a discussion on different update methods see [here](https://stackoverflow.com/questions/6770350/rails-update-attributes-without-save?rq=1)

## Deleting Records
To delete an ActiveRecord object, first pull the object from the database and then destroy it with the `destroy` method. The `destroy` method returns the destroyed object.  

```ruby
user = User.first

user.destroy
#sql: DELETE FROM "users" WHERE "user"."id" = <user's id>
```

