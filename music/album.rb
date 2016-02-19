require_relative '../lib/sql_object'
require_relative '../lib/db_connection'


DBConnection.open(MUSIC_DB_FILE)

class Album < SQLObject
end

Album.finalize!

Album.belongs_to("band")

sticky_fingers = Album.find(1)
puts sticky_fingers.band
