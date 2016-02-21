require_relative 'db_connection'
require_relative 'sql_object'
require 'byebug'

class SQLRelation
  attr_reader :klass, :collection, :loaded
  attr_accessor :included_relation

  def initialize(options)
    defaults =
    {
      klass: nil,
      loaded: false,
      count: false,
      collection: []
    }

    @klass      = options[:klass]
    @collection = options[:collection] || defaults[:collection]
    @loaded     = options[:loaded]     || defaults[:loaded]
    @sql_count  = options[:count]      || defaults[:count]
  end

  def table_name
    klass.table_name
  end

  def <<(item)
    if item.class == klass
      @collection << item
    end
  end

  def to_a
    self.load.collection
  end

  def where_params_hash
    @where_params_hash ||= {}
  end

  def where(params)
    where_params_hash.merge!(params)
    self
  end

  def sql_params
    params, values = [], []

    where_params_hash.map do |attribute, value|
      params << "#{attribute} = ?"
      values << value
    end

    { params: params.join(" AND "),
      where: params.empty? ? nil : "WHERE",
      values: values }
  end

  def count
    @sql_count = true
    load
  end

  def limit(n)
    @sql_limit = n
    self
  end

  def includes(klass)
    @includes_params = klass
    self
  end

  def includes_params
    @includes_params ||= nil
  end

  def load
    if !loaded
      puts "LOADING #{table_name}"
      debugger
      results = DBConnection.execute(<<-SQL, *sql_params[:values])
        SELECT
          #{sql_count ? "COUNT(*)" : self.table_name.to_s + ".*"}
        FROM
          #{self.table_name}
        #{sql_params[:where]}
          #{sql_params[:params]}
        #{"LIMIT #{sql_limit}" if sql_limit};
      SQL

      results = sql_count ? results.first.values.first : parse_all(results)
    end

    results = results || self

    if includes_params
      results = load_includes(results)
    end

    results
  end

  def load_includes(relation)
    if relation.klass.has_association?(includes_params)
      puts "LOADING #{includes_params.to_s}"
      assoc = klass.assoc_options[includes_params]
      f_k = assoc.foreign_key
      p_k = assoc.primary_key
      includes_table = assoc.table_name.to_s
      in_ids = relation.collection.map do |sqlobject|
        sqlobject.id
      end.join(", ")

      has_many = assoc.class == HasManyOptions

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{includes_table}.*
        FROM
          #{includes_table}
        WHERE
          #{includes_table}.#{has_many ? f_k : p_k}
        IN
          (#{in_ids});
      SQL
      included = assoc.model_class.parse_all(results)
      SQLRelation.build_association(relation, included)
    end

    relation
  end

  def self.build_association(base, included)
    base.included_relation = included

    assoc_options = base.klass.assoc_options[base.includes_params]
    has_many = assoc_options.class == HasManyOptions

    if has_many
      i_send = assoc_options.foreign_key
      b_send = assoc_options.primary_key
    else
      i_send = assoc_options.primary_key
      b_send = assoc_options.foreign_key
    end

    match = proc do
      selection = included.select do |i_sql_obj|
        i_sql_obj.send(i_send) == self.send(b_send)
      end

      associated = has_many ? selection : selection.first

      #After we find our values iteratively, we overwrite the method again
      #to the result values to reduce future lookup time to O(1).
      new_match = proc { associated }
      SQLObject.define_singleton_method_by_proc(
        self, base.includes_params, new_match)

      associated
    end

    #we overwrite the association method for each SQLObject in the
    #collection so that it points to our cached relation and doesn't fire a query.
    base.collection.each do |b_sql_obj|
      SQLObject.define_singleton_method_by_proc(
        b_sql_obj, base.includes_params, match)
    end
  end

  def parse_all(attributes)
    klass.parse_all(attributes).where(where_params_hash).includes(includes_params)
  end

  def method_missing(method, *args, &block)
    self.to_a.send(method, *args, &block)
  end

  private
  attr_reader :sql_count, :sql_limit
end
