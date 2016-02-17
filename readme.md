ActiveRecord Lite
==================

ActiveRecord Lite is an object relational mapping inspired by Rails' ActiveRecord.
It converts tables in a SQLite database into instances of the SQLObject class.

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
