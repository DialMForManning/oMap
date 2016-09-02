require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  
  def where(params)
    where_string = params.map { |attr,param| "#{attr} = ?"}.join(" AND ")

    found = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL
    parse_all(found)
  end

end

class SQLObject
  extend Searchable
end
