require_relative 'db_connection'
require_relative 'sql_object'

class Relation
  attr_reader :klass, :collection
  attr_accessor :loaded

  def initialize(klass, loaded=false)
    @klass = klass
    @collection = []
    @loaded = loaded
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

  def load
    if !loaded
      results = DBConnection.execute(<<-SQL, *sql_params[:values])
        SELECT
          #{self.table_name}.*
        FROM
          #{self.table_name}
        #{sql_params[:where]}
          #{sql_params[:params]};
      SQL
      parse_all(results)
    else
      self
    end
  end

  def parse_all(attributes)
    klass.parse_all(attributes).where(where_params_hash)
  end

  def method_missing(method, *args, &block)
    self.to_a.send(method, *args, &block)
  end
end
