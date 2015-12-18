require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    table = self.table_name
    column_names = params.keys.map { |column| "#{column} = ?"  }.join(" AND ")
    num_fields = params.values.length

    select_query = <<-SQL
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{column_names}
    SQL

    results = DBConnection.execute(select_query, params.values)
    objs = []
    results.each do |result|
      objs << self.new(result)
    end

    objs
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
