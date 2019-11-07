# Associations Part 2

The first post spoke about the three most basic associations in rails - belongs_to, has_one, and has_many. This post will go through the other three - has_one :through, has_many :through, and has_and_belongs_to_many

## Has One Through
#### Relationship Type
Has one through is used to establish a 1:1 relationship that goes through another 1:1 relationship. While this may not be techincally correct imagine we have a 1:1 relationship that we'll call a:b. And then we have another 1:1 relationship that we'll call b:c. In such a case, there is also a 1:1 relationship between a:c. For example, we can have three models, user, account, order history. A user has one account and the account has one order history. Therefore the user also has one order history through the account. In the database, the account table would have a user_id column and the order history table would have an account_id column. 

#### Syntax
```ruby
class User < ApplicationRecord
  has_one :account
  has_one :order_history, through: :account
end

class Account < ApplicationRecord
  has_one :order_history
end
```
Note that this is what is required for the user to directly access the order history. For the account_history to go back to user there is no belongs to through association. See [here](https://stackoverflow.com/questions/4021322/belongs-to-through-associations) for more details about how to handle this situation. 

#### Methods
This relationship allows you to access order_history data directly from the user. While in theory this could be accomplished with `user.account.order_history` the main difference between that statemenet and `user.order_history` is the type of sql query that is used to access the order history. With `user.account.order_history`, two db queries are required, but with `user.order_history`, the db is queried only once with a join statemenet. 

```ruby
author = Author.take
author.book.order_history

#sql:
SELECT  "books".* FROM "books" WHERE "books"."author_id" = <author's id> LIMIT 1
SELECT  "order_histories".* FROM "order_histories" WHERE "order_histories"."book_id" = <author's book's id> LIMIT 1

author.order_history
SELECT  "order_histories".* FROM "order_histories" INNER JOIN "books" ON "order_histories"."book_id" = "books"."id" WHERE "books"."author_id" = <author's id> LIMIT 1
```

Note that there is no `author.build_order_history` method. 

## Has And Belong To Many
#### Relationship Type
Has and belong to many is used to set up a direct many to many association. For example, a student has many courses and courses have many students. So the students need to access their courses and the courses need to access their students. In the database there should be a third table, courses_studnets (courses preceds students because 'courses' > 'students' in ruby string comparison) that contains a foreign key column for student_id and a foreign key column for course_id. 

#### Syntax
```ruby
class Student < ApplicationRecord
  has_and_belongs_to_many :courses
end

class Course < ApplicationRecord
  has_and_belongs_to_many :students
end
```
#### Methods
The methods that are created by has_and_belongs_to_many are similar to has_many with a few differences. Obviously given the fact that the two models are associated in the database in a third table, the SQL statements generated are very different. 

1) #students . Return `Student::ActiveRecord_Associations_CollectionProxy` object with students. 

```ruby
course = Course.take
course.students

#sql:  SELECT "students".* FROM "students" INNER JOIN "courses_students" ON "students"."id" = "courses_students"."student_id" WHERE "courses_students"."course_id" = <course's id>
```

2) #students << . Adds passed in student objects to the course. Automatically sends them to the db. If the student object does not exist, it is saved to the db. The student can (and should, it is an M:M) be associated with another course.

```ruby
course = Course.take
course.students << Student.new

INSERT INTO "students" () VALUES ()
INSERT INTO "courses_students" ("course_id", "student_id") VALUES (<courses_id>, <students_id>)
```

3) #students.delete . Removes row from the join table, doesn't remove the object from it's own table in the db

```ruby
course = Course.take
student = course.students.take

course.students.delete student

sql: DELETE FROM "courses_students" WHERE "courses_students"."course_id" = <course's id> AND "courses_students"."student_id" = <student's id>
```

4) #students= . replaces students with the students passed in. 

```ruby
course = Course.take
students = Student.take(2)

course.students = students

#sql
DELETE FROM "courses_students" WHERE "courses_students"."course_id" = <courses id> AND "courses_students"."student_id" IN (previous student's id, ..., ...)
INSERT INTO "courses_students" ("course_id", "student_id") VALUES (<course's id>, <student's id>) #does this for each student object in students. 
```

5) #student_ids (note singular). Returns arr of students ids. (query similar to #students, except that it only selects students.id from the db)
6) #student_ids= (note singular). Sets values for student's ids based on passed in id's. (query similar to #students= )

7) #students.clear . Removes association, doesn't destroy objects

8) #students.empty?
9) #students.size
10) #students.find(student_id)
11) #students.create . creates object and gives it the proper association in the join table

```ruby
course = Course.take
course.student.create

INSERT INTO "students" () VALUES ()
INSERT INTO "courses_students" ("course_id", "student_id") VALUES (<courses_id>, <students_id>)

```

## Has Many Through
#### Relationship Type
Has many through is used to create a M:M relationship through another model. For example,   As opposed to has and belongs to many, where the two related models are in a separate join table not associated with a model, in has many through, there is a third table for the joining model which contains 

#### Syntax
```

```
#### Methods



