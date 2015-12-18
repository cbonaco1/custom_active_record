require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns

    return @columns if @columns

    #get the column names and put them in an array
    column_names = []
    results = DBConnection.execute2(<<-SQL)
      SELECT * FROM #{table_name}
    SQL

    #convert each column_name to a symbol
    @columns = results.first.map { |column_name| column_name.to_sym  }
  end

  def self.finalize!
    #adds a setter and getter for each column
    columns.each do |column_name|
      #getter
      define_method("#{column_name}") do
        #read the value at attributes[column_name]
        attributes[column_name]
      end

      #setter
      #didnt have equal sign on before so it was using getter
      define_method("#{column_name}=") do |arg|
        #set the value at attributes[column_name]
        attributes[column_name] = arg
      end
    end

  end

  def self.table_name=(table_name_in)
    @table_name = table_name_in
  end

  def self.table_name
    @table_name || to_s.tableize
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
      #self is the Class here, since we're in a class method?
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

    #Nicer way to do this?
    #Only return new object if result from query is not nil
    if result.first.nil?
      return nil
    else
      return self.new(result.first)
    end

  end

  def initialize(params = {})
    params.each do |column_name, value|
      column_name = column_name.to_sym

      #self is the object we're trying to create?
      unless self.class.columns.include?(column_name)
        raise "unknown attribute '#{column_name}'"
      end

      #set attribute by calling setter using send
      self.send("#{column_name}=", value)
    end
  end

  def attributes
    @attributes || @attributes = {}
    # if @attributes
    #   @attributes
    # else
    #   @attributes = {}
    # end
  end

  def attribute_values
    #one attribute short
    # attributes.values

    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    #self is an instance of class
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
    #self is an instance of class
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

    puts update_query
    p attribute_values
    result = DBConnection.execute(update_query, attribute_values)
  end

  def save
    self.class.find(self.id) ? update : insert
  end
end
