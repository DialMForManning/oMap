require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns

    all_cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @columns = all_cols.first.map!(&:to_sym)
  end

  def self.make_helpers!
    columns.each do |col_name|
      define_method(col_name) { attributes[col_name] }

      define_method("#{col_name}=") { |value| attributes[col_name] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
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
    set_cols = cols_no_id.map { |name| "#{name} = ?" }.join(",")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_cols}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  private
  def cols_no_id
    self.class.columns.drop(1)
  end
end
