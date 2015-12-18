require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns

    return @columns if @columns

    column_names = []
    results = DBConnection.execute2(<<-SQL)
      SELECT * FROM #{table_name}
    SQL

    @columns = results.first.map { |column_name| column_name.to_sym  }

  end

  def self.finalize!
    
  end

  def self.table_name=(table_name_in)
    @table_name = table_name_in
  end

  def self.table_name
    @table_name || to_s.tableize
 end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    finalize!
  end

  def attributes
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
