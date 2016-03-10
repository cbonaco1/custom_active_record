require_relative '../lib/sql_object'
require_relative '../lib/db_connection'

DBConnection.open(MUSIC_DB_FILE)

# This file is intended to mimic a Model class in a Rails application
# This file demonstrates some use cases of the SQLObject class

class Band < SQLObject
end

Band.finalize!

led_zepplin = Band.new({name: "Led Zepplin"})
p Band.all
puts Band.where({name: "The Beatles"})
