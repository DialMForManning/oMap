require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = cols.first.map!(&:to_sym)
  end

  def self.finalize!
    columns.each do |col_name|
      define_method(col_name) { attributes[col_name] }

      define_method("#{col_name}=") { |value| attributes[col_name] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    name = self.to_s.split /(?=[A-Z])/
    "#{name.map(&:downcase).join('_')}s"
  end

  def self.all
    all_hashes = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(all_hashes)
  end

  def self.parse_all(results)
    results.map { |attrs_hash| self.new(attrs_hash) }
  end

  def self.find(id)
    attrs = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(attrs).first
  end

  def initialize(params = {})
    params.each do |attr, value|
      unless self.class.columns.include?(attr.to_sym)
        raise "unknown attribute '#{attr}'"
      end

      self.send("#{attr}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |value| self.send(value) }
  end

  def insert
    cols_no_id = self.class.columns.drop(1)
    col_names = cols_no_id.map(&:to_s).join(",")
    question_marks = (["?"]*cols_no_id.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
