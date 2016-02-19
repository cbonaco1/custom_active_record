require_relative 'searchable'
require_relative 'db_connection'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  extend Searchable

  #Creating a new object:
  # track = Track.new(name: "Brown Sugar", album_id: 2)
  def initialize(params = {})
    params.each do |column_name, value|
      column_name = column_name.to_sym

      #throw an error if the column name passed in does not exist
      #in the table's columns
      unless self.class.columns.include?(column_name)
        raise "unknown attribute '#{column_name}'"
      end

      #set attribute by calling setter using send
      self.send("#{column_name}=", value)
    end
  end

  #Returns an array of the column names for a table as symbols
  def self.columns

    #This only allows the query to be run once
    #If we've retrieved the columns already, dont run query again
    return @columns if @columns

    column_names = []
    results = DBConnection.execute2(<<-SQL)
      SELECT * FROM #{table_name}
    SQL

    #convert each column_name to a symbol
    @columns = results.first.map { |column_name| column_name.to_sym  }
  end

  #Class getter/setter methods for table_name
  def self.table_name=(table_name_in)
    @table_name = table_name_in
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  #creates a setter and getter for each column
  def self.finalize!
    columns.each do |column_name|
      #getter
      define_method("#{column_name}") do
        #read the value at attributes[column_name]
        attributes[column_name]
      end

      #setter
      define_method("#{column_name}=") do |arg|
        #set the value at attributes[column_name]
        attributes[column_name] = arg
      end
    end

  end

  def self.all
    table = self.table_name
    #only add args on to this if using quesiton mark
    #Can only use question mark in WHERE (for values, not table/col names)
    result = DBConnection.execute(<<-SQL)
      SELECT
        #{table}.*
      FROM
        #{table}
    SQL

    parse_all(result)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      #Create new instances of self for each record returned
      objects << self.new(result)
    end

    objects
  end

  def self.find(id)
    table = self.table_name
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table}.*
      FROM
        #{table}
      WHERE
        #{table}.id = ?
    SQL

    #Only return new object if result from query is not nil
    if result.first.nil?
      return nil
    else
      return self.new(result.first)
    end

  end

  def attributes
    @attributes || @attributes = {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  #Inserting an instance of the class into the database
  def insert
    table  = self.class.table_name
    column_names = self.class.columns.join(", ")
    num_fields = self.class.columns.length
    fields = (["?"] * num_fields).join(", ")

    result = DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{table} (#{column_names})
      VALUES
        (#{fields})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    table  = self.class.table_name
    column_list = self.class.columns.map{ |column| "#{column} = ?" }
    column_list = column_list.join(", ")

    update_query = <<-SQL
    UPDATE
      #{table}
    SET
      #{column_list}
    WHERE
      id = #{id}
    SQL

    result = DBConnection.execute(update_query, attribute_values)
  end

  def save
    self.class.find(self.id) ? update : insert
  end
end
