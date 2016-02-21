require_relative 'db_connection'
require_relative 'associatable'
require_relative 'relation'
require 'active_support/inflector'

class SQLObject
  extend Associatable

  def self.columns
    @table ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name};
      SQL
    @table.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |new_value|
        attributes[column] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.tableize
  end

  def self.parse_all(results)
    relation = SQLRelation.new(klass: self, loaded: true)
    results.each do |result|
      relation << self.new(result)
    end

    relation
  end

  def self.find(id)
    self.where(id: id).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    column_names = self.class.columns.join(", ")
    question_marks = self.class.columns.map{|c| "?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{question_marks});

    SQL
    self.id = DBConnection.last_insert_row_id
    self
  end

  def update
    set_line = self.class.columns.map do |column|
      "#{column} = \'#{self.send(column)}\'"
    end.join(", ")

    DBConnection.execute(<<-SQL, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
    self
  end

  def save
    self.class.find(id) ? update : insert
  end

  def destroy!
    if self.class.find(id)
      DBConnection.execute(<<-SQL, id)
        DELETE
        FROM
          #{self.class.table_name}
        WHERE
          id = ?
      SQL
      return self
    end
  end

  def self.destroy_all!
    self.all.each do |entry|
      entry.destroy!
    end
  end

  def self.has_association?(association)
    assoc_options.keys.include?(association)
  end

  def self.define_singleton_method_by_proc(obj, name, block)
    metaclass = class << obj; self; end
    metaclass.send(:define_method, name, block)
  end

  def self.limit(num)
    SQLRelation.new(klass: self).limit(num)
  end

  def self.includes(klass)
    SQLRelation.new(klass: self).includes(klass)
  end

  def self.where(params)
    SQLRelation.new(klass: self).where(params)
  end

  def self.all
    self.where({})
  end

  def self.count
    self.all.count
  end
end
