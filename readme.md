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

###Tested and true

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

###SQLRelation
Has the basic functionality of ActiveRecord::Relation, allowing us to
order and search DB entries with minimal querying.

All methods are lazy and stackable. Queries are only fired when SQLRelation#load
is called or when the relation is coerced into an Array.

Methods included:
  * All
  * Where
  * Includes
  * Find
  * Order
  * Limit
  * Count
  * First
  * Last

###Eager loading reduces queries
* Preload has_many and belongs_to associations by calling SQLObject#includes
  * Lazy and chainable.
  * Reduces your DB queries from (n + 1) to 2.

###Coming Soon
* [x] Relations
* [x] Relation#includes
* [ ] Relation#joins
* [ ] Migrations
