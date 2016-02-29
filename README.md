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
* `searchable.rb`
..Implements basic SQL query clauses such as `where`
* `associatable.rb`
..Implements associations `has_many`, `belongs_to`, and `has_one_through`
* `db_connection.rb`
..Contains logic for making a connection to the database and executing queries
* `sql_object.rb`
..This class extends both `Searchable` and `Associatable` modules, and
contains logic for the main features of the ORM. For example,
the `::all` method will make a connection to the database using a db_connection object,
and execute a query to select all from the receiver, which is the name of the table to query.

### Testing
Using RSpec, I developed a suite of tests which test the features of the ORM.
These tests can be run by executing the following command:
`$ bundle exec rspec`
