#Todo List Tool
###Description
- Create, store, and update multiple todo lists in a local database
- Start by adding a new todo list
- Your new list will be assigned a unique id which can be used to load or delete it in the future
- New entries will be set to 'unfinished' by default

###Setup
- Fork this repo
- Clone this repo
- Enter the following in the terminal under the path of your cloned directory:

```
$ bundle install 
$ rake db:migrate
```
- Now you can run the ruby console file:

```
$ ruby console.rb
```
- You should then be prompted with the start up options
- Make sure your terminal window is open wide and/or your terminal font size is small to avoid text wrapping and crashing for larger entries
- Quit the program at any time by entering `ctr + c` selecting `exit` under the start up options

###Topics
- Become familiar with sqlite and Active Record
- Be able to write a migration
- Be able to create and update records in database
- Be able to write a descriptive and accurate README
- Be able to query, manipulate, and save rows in a database
- Be able to create a command line app by referencing past projects
- Be able to use a project skeleton

###Takeaway

- I was uncomfortable with Active Record and database migrations at first, think I have a solid grasp of the basics after this project
- Ultimately I'm grateful to get to use Active Record since it distances the programmer from sql when communicating with a database, keeping us in happy 'Ruby Land'


###Contents of this repo

```
.
├── Gemfile             	# Details which gems are required by the project
├── README.md           	# This file
├── Rakefile            	# Defines `rake generate:migration` and `db:migrate`
├── config
│   └── database.yml    	# Defines the database config (e.g. name of file)
├── console.rb          	# `ruby console.rb` starts `pry` with models loaded
├── db
│   ├── dev.sqlite3     	# Default location of the database file
│   ├── migrate         	# Folder containing generated migrations
│   └── setup.rb       		# `require`ing this file sets up the db connection
└── lib                 	# Your ruby code (models, etc.) should go here
	└── keep
	└── todo_list.rb		# model for 'todo_lists' table
	└── todo_list_tool.rb	# main program code
    └── all.rb          	# Require this file to auto-require _all_ `.rb` files in `lib`
```




