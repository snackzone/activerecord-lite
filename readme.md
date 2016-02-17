ActiveRecord Lite
==================

ActiveRecord Lite is an object relational mapping inspired by Rails' ActiveRecord.
It converts tables in a SQLite database into instances of the SQLObject class.

SQLObject is a very lightweight version of ActiveRecord::Base, but is easily customizable.
It's a great way to use ActiveRecord::Base's CRUD methods and associations without all the
extra overhead.

##Try it out
1. Clone the repo
2. Load the demo file in Pry.

The demo contains a small database and the following classes, which inherit from SQLObject:
  * House
  * Human
  * Cats

See the demo file for the pre-built associations.

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
* SQLObject#where takes a params hash and uses it to query the db, returning all matches.
