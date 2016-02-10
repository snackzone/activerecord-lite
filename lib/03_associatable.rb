require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Object.const_get(class_name)
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] ||
                    "#{self_class_name.downcase.singularize}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key_value = self.send(options.foreign_key)
      return nil if foreign_key_value.nil?

      results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{options.table_name}
      WHERE
        #{options.primary_key} = #{foreign_key_value};
      SQL

      options.model_class.new(results.first)
    end
  end
  #
  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.table_name, options)

    define_method(name) do
      target_key_value = self.send(options.primary_key)
      return nil if target_key_value.nil?

      results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{options.table_name}
      WHERE
        #{options.foreign_key} = #{target_key_value};
      SQL

      options.model_class.parse_all(results)
    end
  end

  def has_one_through(name, through_name, source_method)
    through_values = assoc_options[through_name]
    through_options = BelongsToOptions.new(through_name, through_values)

    source_values = through_options.model_class.assoc_options[source_method]
    source_options = BelongsToOptions.new(source_method, source_values)


    raise "error" if through_options.nil?

    define_method(name) do

    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
