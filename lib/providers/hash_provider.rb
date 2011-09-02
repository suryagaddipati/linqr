require 'providers/enumerable_provider'

class HashProvider < EnumerableProvider

  def handle_where(linq_exp)
    filtered_values = @enumerable.lazy_select do|k,v| 
      Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
      Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
      linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

  def handle_select(linq_exp,filtered_values)
    filtered_values.lazy_map do |k,v|
      Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
      Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

end

class  Hash
  def linqr_provider
    HashProvider.new(self)
  end
end
