#### Generating Models
The two models we're generating are TodoList and TodoItem. The following code generate the models with the neccesary migration files. The migrations are updated to add database validations. One note about the validation on the todo_items is that we're requiring that we not have entries where the name and the todo_list_id pair is a duplicate. Todo items can have the same if they belong to different lists, but within the same list they must be unique. 

```
rails g model TodoList name:text

Migration File:
class CreateTodoLists < ActiveRecord::Migration[5.0]
  def change
    create_table :todo_lists do |t|
      t.text :name
      t.index :name, unique: true #added this line manually
      
      
      t.timestamps
    end
  end
end
```

```
rails g model TodoItem name:text todo_list:references completed:boolean

Migration File
class CreateTodoItems < ActiveRecord::Migration[5.0]
  def change
    create_table :todo_items do |t|
      t.text :name
      t.references :todo_list, foreign_key: true
      t.boolean :completed, default: false

      t.index [:name, :todo_list_id], unique: true #added this line manually
      
      t.timestamps
    end
  end
end
```

Then we add the correct associations and validations to the models:
```
class TodoList
  has_many :todo_items, dependent: :destroy
  
  validates :name, presence: true, 
                   length: { maximum: 100 },
                   uniqueness: { case_sensitive: false }
end

class TodoItem
  belongs_to :todo_list
  
  validates :name, presence: true,
                   length: { maximum: 100 }
                   uniqueness: { scope: :todo_list_id }
end
```

See the test files in the github repo under test/models/todo_item_test.rb and test/models/todo_list_test.rb

#### Generating The Controllers
There are two controllers TodoLists and TodoItems.

```
rails g controller TodoLists
rails g controller TodoItems
```

We'll modify the routes page so that the todo item pages are nested within the todo lists.

```
# routes.rb

Rails.application.routes.draw do
  
  root 'todo_lists#index'
  
  resources :todo_lists do
    resources :todo_items, only: [:create, :destroy]
  end
  
end
```

#### MVC
We're now ready to start working on the actions and their corresponsing views. The first thing we have to do though is get the db ready with some data. 

```ruby
# db/seeds.rb
3.times do |num|
  list = TodoList.create(name: "list #{num + 1}")
  
  3.times do |num|
    completed = num.odd?
    list.todo_items.create(name: "item #{num + 1}", completed: completed)
  end
end
```

Running `rails db:seed` will add 3 lists each with 3 items. 

##### index
For the index action we need to get all the todo lists and the counts of the number of todo items and the count of the todo items that are completd. To do this we'll add a scope to the TodoList model that executes a left outer join and counts the number of todo items and how many are completed. We'll then call this method in the controller for the index action.

```
# app/models/todo_list.rb

Class TodoList < ApplicationRecord
  
  ...

  scope :all_with_item_completed_counts, 
        -> { TodoList.select("todo_lists.*, COUNT(todo_items.id) AS todo_items_count, COUNT(todo_items.completed = 1) AS todo_items_completed")
        .left_outer_joins(:todo_items)
        .group(:id) }
        
end
```
```
# app/controllers/todo_lists_controller.rb

Class TodoListsController < ApplicationController
  def index
    @todo_lists = TodoList.all_with_item_completed_counts
  end
end

```

In the view we'll start by iterating over the lists and adding links to their show pages. We'll use rails link_to with the optional block to specify the html within the link. Inside the link we'll render the name of the list, followed by the number of completed out of the total number of items.

```ruby
<ul id="lists">
  <% @todo_lists.each do |list| %>
  	<li class="">	
      <%= link_to list do %>
       	<h2><%= list.name %></h2>
       	<p><%= list.todo_items_completed  %>/<%= todo_items_count %></p>
      <% end %>
    </li>
  <% end %>
</ul>
```

##### new

