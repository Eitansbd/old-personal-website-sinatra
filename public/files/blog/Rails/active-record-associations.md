# Associations
Associations are relationships between ActiveRecord models. Declaring the way different models are related to each other allows for a simple way to do basic tasks, such as retrieving the related data from the database, setting the foreign key id value and cascading deletes. In order to get the methods for both classes in the relationship, the association has to be declared in both classes. Declaring an association in one class has no impact on the class that is associating with. One important note is that declaring relationships in a model has no impact on the database. Foreign key's have to be added separately with a migration in order for the association functions to work properly. See [below](#broken-associations) for a detailed explanation of what happens when declared associations or database columns are missing.

There are 6 association types in rails:
1) belongs_to
2) has_one
3) has_many 
4) has_many :through
5) has_one :through
6) has_and_belogs_to_many


## belongs_to
#### Relationship type
The belongs to association is used to define either a 1:1 or M:1 (1:M from the opposite viewpoint) relationship. For example, a profile belongs to a user, and a user only has one profile (1:1), but a book belongs to an author and an author can have many books (M:1). Whether the relationship is 1:1 or M:1 depends on the association in the other class and doesn't affect the current class. In both cases, the foreign key should be in the table of the class that declares the belongs_to association (profiles would contain a column user_id and books would contain a column author_id). 

#### Syntax
```ruby
class Book
  belongs_to :author
end
```

#### Methods
1) Author getter method, returns an author object. queries database on first call and saves to author instance variable
```ruby
book = Book.take
book.author 
# sql: SELECT  "authors".* FROM "authors" WHERE "authors"."id" = <books author_id>
```
2) Author setter method, expects an author object to be passed in. If the author doesn't exist in the db, The author will be added. `ActiveRecord::AssociationTypeMismatch` will be raised if given an object other than an Author
```
book = Book.new
book.author = Author.new
book.save
# first inserts author into authors table, then book into books table
```

see [here](https://apidock.com/rails/ActiveRecord/Associations/ClassMethods/belongs_to) for more methods and full discussion

## has_one
#### Relationship type
Has one is used to describe one side of a 1:1 relationship (with the other side being belongs_to). For example, a user has on profile. The foreign key column is in the table of the other class. 
#### Syntax
```ruby
class User
  has_one :profile # note that it's singular 
end
```
#### Methods
1) Profile getter method. Returns first profile associated with the user (given that it's a 1:1 there should only be one profile per user), `nil` if the user doesn't have a profile
```
user = User.take
user.profile
#sql: SELECT  "profile".* FROM "profile" WHERE "profile".user_id" = <user's is> LIMIT 1
```

2) Profile setter method. 

see [here](https://apidock.com/rails/v5.2.3/ActiveRecord/Associations/ClassMethods/has_one) for more 
## Adding foreign keyss in a migration

## Has Many
#### Relationship Type
Has many is used to describe a 1:M relationship (with the other side containing belongs_to). For example, an author has many books. The foreign key column is in the table of the other class. 
#### Syntax
```ruby
class Author
  has_many :books # note that it's plural
end  
```
#### Methods
1) books. Getter method for authors books. Returns a Book::ActiveRecord_Associations_CollectionProxy object which contains the book objects (in instance variable records).
```ruby
author = Author.take
author.books 
#sql:  SELECT "books".* FROM "books" WHERE "books"."author_id" = ?
```
2) books= . Setter method for authors books. Iterates through the books and updates the foreign key in the database automatically (ie without calling author.save)
```
author = Author.take
books = Book.take(2)

author.books = books
#sql: UPDATE "books" SET "updated_at" = <current time stamp>, "author_id" = <authors id> WHERE "books"."id" = <current book in the iterations id> 
```
(I'm not exactly sure what kind of object author.books is expecting. `Book.take(2).class` returns Array, so I thought that `author.books` is expecting an array, but then I created an array manually with `Book` objects and got a `ActiveRecord::AssociationTypeMismatch (Book(#35401700) expected, got Array(#16627420))` error)

3) books_ids. Getter method for the id's of the author's books. If the books are already loaded into the author, the db is not queried. 
```ruby
author = Author.take
author.book_ids 
sql: SELECT "books".id FROM "books" WHERE "books"."author_id" = <authors id>
```

4) books_ids= . Setter methods for author's books. Takes in either an integer or an array of integers. First the methods loads the books into author.books, then updates the database and a) removes author_id value for books that previously belonged to this author but now no longer and b) sets the value for author_id to the current author for books that previously didn't belong to this author and now do. Exactly how this method works and when values from the db are deleted/updated depends on how the previous list of book_ids differs from the current_list of book ids. 

```
author = Author.take
author.book_ids = [2,3]
sql: SELECT "books".* FROM "books" WHERE "books"."id" IN (2, 3)
sql: UPDATE "books" SET "author_id" = ?, "updated_at" = ? WHERE "books"."id" = ?
```

5) books<< . Expecting a book object. If the book does not exist in the db, it will be added with a author_id value of the author. If it does exist, it will be updated with the author_id value of the author. One thing to keep in mind is that the method also loads the books if they are not yet loaded. If doing so is a waste of time because all that's neccesary is to add the book don't use this method (instead you can set the author id from the book side using book.author = or by creating the book through the author.)

6) books.find(book_id) - works the same as class call to find
7) books.size
8) books.empty?
9) books.new / books.create

## Adding foreign keys in a migration

`rails g migration AddAuthorToBooks author:references`
creates this migration file:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[5.0]
  def change
    add_reference :books, :author, foreign_key :true 
    # the last arg foreign_key :true is really a hash
  end
end
```
this adds an author_id column to the books table, with a foreign key constraint


## Interesting notes
#### Broken Associations
1) Lets say you declare in the Author class that an Author has many books, but the book model has not been created yet. If you try to access the books of an Author, an NameError exception will be raised:

```ruby
class Author
  has_many :books
end

## in the console
author = Author.first
author.books # NameError (uninitialized constant Author::Book)

```

Now lets say you created the Book model but haven't added the book table to the db with a migration. In such a case an ActiveRecord::StatementInvalid exception will be raised
```ruby
class Author
  has_many :books
end

class Books
end

## in the console
author = Author.first
author.books # ActiveRecord::StatementInvalid (Could not find table 'books')

```
Now lets say you add the book table to the db, but you don't create the an association in the db between the books and authors (books does not contain an author_id column). In such a case an ActiveRecord::StatementInvalid exception will be raised

```ruby
class Author
  has_many :books
end

class Books
end

## in the console
author = Author.first
ActiveRecord::StatementInvalid (SQLite3::SQLException: no such column: books.author_id: SELECT "books".* FROM "books" WHERE "books"."author_id" = ?)
```

Finally, when you add an author_id column to the books table, calling the books method on an author object will do the following:
- run the following sql:
  `SELECT "books".* FROM "books" WHERE "books"."author_id" = <author's id>`
- return a Book::ActiveRecord_Associations_CollectionProxy object. This object has a `records` instance variable which returns an array of all the objects pulled from the sql query


2) When methods make sql queries and when they don't is really smart. The first time you call `author.books`, the books associated with that author are loaded from the database, but they are also saves to the books attribute of the author. Subsequent calls to author.books won't query the database and will just return the data stored in `author`. If you reload the author, the books instance variable is reset as well. 
```ruby
author = Author.take
author.books # DB query
author.books # no DB query
author.reload
author.books # DB query
```

Where things get more interesting is when you call the `any?` or`none?` methods on the authors books. calling `author.books.any?` doesn't load the books from the database, it simply checks if any books exist with this sql query: `SELECT  1 AS one FROM "books" WHERE "books"."author_id" = <authors id> LIMIT = 11  `. Because the books weren't loaded, a call afterwards to `author.books` has to load the books from the database. But, if the books were first loaded to the author with `author.books` and then afterwards you check if there are any books with `author.books.any?`, the db is not queried on the `any?` method call

```ruby
author = Author.take
author.books.any? # simple DB query to check for book presence, no books loaded
author.books # DB query, books loaded
author.books.any? # no DB query
```








