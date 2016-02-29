## ActiveRecordLite

This application is a from-scratch implementation of an Object Relational Mapping (ORM), with features based on
the ActiveRecord ORM used in the Rails web framework. I completed this project
in order for me to gain a better understanding of how ORMs and ActiveRecord work.
A SQLite database representing a music label inventory is included in order
to test this implementation. The schema for the music database can be viewed [here].

[here]: ./docs/schema.md

### Setup
To test the ORM, clone the repo into a folder and run the following commands:

`$ bundle install`
Installs the required gems

`$ sqlite3 music_inventory.db`
Loads the music inventory SQLite database

In the `/lib` folder, there are several different files which provide the functionality of the ORM:
* `searchable.rb` - implements basic SQL query clauses such as `where`
* `associatable.rb` - implements associations `has_many`, `belongs_to`, and `has_one_through`
* `db_connection.rb` - contains logic for making a connection to the database and executing queries
* `sql_object.rb` - this class extends both `Searchable` and `Associatable` modules, and methods
written in this class represent the main features of the ORM.

### Testing
Using RSpec, I developed a suite of tests which test the features of the ORM.
These tests can be run by executing the following command:
`$ bundle exec rspec`
