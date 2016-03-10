require_relative '../lib/sql_object'
require_relative '../lib/db_connection'

DBConnection.open(MUSIC_DB_FILE)

# This file is intended to mimic a Model class in a Rails application
# This file demonstrates some use cases of the SQLObject class

class Album < SQLObject
end

Album.finalize!

Album.belongs_to("band")

sticky_fingers = Album.find(1)
sticky_fingers.band == "The Rolling Stones"
