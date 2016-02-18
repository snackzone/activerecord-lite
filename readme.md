ActiveRecord Lite
==================

ActiveRecord Lite is an object relational mapping inspired by Rails' ActiveRecord.
It converts tables in a SQLite database into instances of the SQLObject class.

SQLObject is a very lightweight version of ActiveRecord::Base, but is easily customizable.
It's a great way to use ActiveRecord::Base's CRUD methods and associations without all the
extra overhead.

SQLRelation imitates the behavior of ActiveRecord::Relation, making sure no unnecessary
queries are made to the DB.

##Try it out
1. Clone the repo
2. Load the demo file in Pry.

The demo contains a small database and the following classes, which inherit from SQLObject:
  * House
  * Human
  * Cats

See the demo file for the pre-built associations.

If you fiddle with the code, you can run the tests to make sure you didn't break anything 
(bundle exec rspec spec).

###All of your favorite methods are present, including:
* Create
* Find
* All
* Update
* Destroy

###Also builds Rails table associations:
* Belongs to
* Has many
* Has one through
* Has many through

###Did I mention it's searchable?
* SQLObject#where takes a params hash.
* #where method calls are:
  * Stackable. SQLObject#where returns a Relation instance
  * Manipulatable. SQLRelation instances respond to all Array instance methods
  * Lazy. Queries only fire when necessary, i.e. when the SQLRelation is coerced into an array
  (you can also call SQLRelation#load to force this).

###Coming Soon
* [x] Relations!
* [ ] Relation#includes
* [ ] Relation search methods
* [ ] Migrations!
