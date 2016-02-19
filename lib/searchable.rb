require_relative 'db_connection'
require_relative 'sql_object'

module Searchable

  # haskell_cats = Cat.where(:name => "Haskell", :color => "calico")
  def where(params)
    table = self.table_name
    column_names = params.keys.map { |column| "#{column} = ?"  }.join(" AND ")

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
