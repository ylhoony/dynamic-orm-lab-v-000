require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attributes)
    wheres = []
    attributes.each do |key, value|
      wheres << '"#{key.to_s}"= "#{value}"'
      # binding.pry
    end
    params = wheres.join(", ")
binding.pry
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE ?
    SQL

    DB[:conn].execute(sql, params)

  end

end
