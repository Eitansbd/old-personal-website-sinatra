##
As part of the Launch School curriculum we built a postgreSQL backed todo app using sinatra. The app doesn't have that much functionality beyond creating and modifying todo lists and items, but does have some extra features like marking all todo items as complete and modifying the ordering and styling of the todo lists depending on how many todo items are complete. In this post I'll go into detail about how I went about rewriting the app in Rails and the things I learned along the way. 

### Sinatra App Code
The first step I took was looking at all the code in the sinatra app. Two main differences between the sinatra version and the new version will be that the sinatra app uses a DAO (database access object) to fire queries wereas the rails app will use ActiveRecord (the default Rails ORM). Another main difference is in the organization of the code. The sinatra app doesn't clearly organize the routes and methods but the Rails app will implement MVC architecture to clearly define the roles of each aspect of the application. One final difference is that I'll be writing tests for the Rails app and following TDD principles. 

### Routes
Looking at the Sinatra code, all the routes fall into one of three categories:
1) '/' - The home page. This will actually be the same as the todo list index
2) endpoints for the todo lists
3) endpoints for the todo items. 

The lists have the complete RESTful set of endpoints - index, show, new, create, edit, update, delete) as well as one other endpoint to mark all the todos for the list as complete. The todos only have two RESTful endpoints - create and delete - as well as one other endpoint for toggling the completed status of the todo. 

### Models and Associations
Based on the structure of the routes and with how the list and items interact we're going to have two models - TodoList and TodoItem. Each todo list has many todo items and each todo item belong to a todo list so the models will declare those associations. 

Validations are fairly simple. Todo list names must exist, be between 1 and 100 characters, and be unique. Todo item names must be between 1 and 100 characters and be unique within their list. 

### Database
Given the association declared above the todo_items table will have a foreign key column todo_list_id that references the id column in the todo_lists table. The todo_lists table will also contain a name column of type text. The todo_items table will also contain a name column of type text and a completed column of type boolean with a default value of false. 


### VC
The only views needed come from the todo_lists controller for index, show, new, and edit. The show view shows the name of the todo list as well as all the todo items that belong to the list. It also contains the form to create a new todo item, delete a todo item, mark all todos as complete, and edit the name of the todo list. The edit view contains the form to update the todo list and delete the todo list.

### Helpers
The helper methods do the following:
1) count the number of todos
2) count the number of todos that are completed
3) check if all todos in a list are complete
4) set the css class of the list to "complete" if the list is complete  
5) sorts the array of lists based on which are complete. 
6) sorts the list of todos by complete. 

Becausee we're not using JavaScript to send AJAX requests, all of these methods could really be removed and accomplished through ActiveRecord methods.

### Conclusion
The Todo app is pretty simple but will serve as a quick way to get a simple rails app up and running quickly. Using Rails and ActiveRecord will significantly cut down the amount of code needed and will make updating the app much easier. In part 2 I'll actually go about making the transition and build the todo app in Rails. 