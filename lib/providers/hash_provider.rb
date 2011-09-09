require 'providers/enumerable_provider'

class HashProvider < EnumerableProvider

  def handle_where(linq_exp)
    filtered_values = @enumerable.lazy_select(&linq_exp.with_vars do|k,v| 
      linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end)
  end

  def handle_select(linq_exp,filtered_values)
    filtered_values.lazy_map(&linq_exp.with_vars do |k,v|
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end)
  end
end

class  Hash
  def linqr_provider
    HashProvider.new(self)
  end
end
