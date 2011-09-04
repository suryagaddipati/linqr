require 'providers/enumerable_expression_evaluator'
require 'lazy_enumerator'
require 'group_by'
class EnumerableProvider
  def initialize(enumerable)
    @enumerable = enumerable.to_enum
  end
  def handle_where(linq_exp)
      @enumerable.lazy_select do|e| 
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
  end

  def handle_order_by(linq_exp,filtered_values)
    order_by = linq_exp.order_by
    order_by.expressions.reduce(filtered_values) do |values, sort_exp|
      values.lazy_sort_by do|e| 
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        sort_val = sort_exp.visit(EnumerableExpessionEvaluator.new(linq_exp))
        order_by.descending?? 1 - sort_val : sort_val
      end
    end
  end

  def handle_group_by(linq_exp,filtered_values)
    grouped_values = filtered_values.group_by do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.group_by.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end

    grouped_values.collect do |(k,v)|
      Object.send(:define_method,linq_exp.group_by.grouping_var) { Grouped.new(k,v) }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

  def handle_select(linq_exp,filtered_values)
    filtered_values.lazy_map do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

  def evaluate (linq_exp)
    filtered_values =linq_exp.where?? handle_where(linq_exp) : @enumerable
    filtered_values = linq_exp.order_by?? handle_order_by(linq_exp,filtered_values) : filtered_values
    if (linq_exp.group_by?)
      handle_group_by(linq_exp,filtered_values)
    else
      handle_select(linq_exp,filtered_values)
    end
  end
end

module  Enumerable
  def linqr_provider
    EnumerableProvider.new(self)
  end
end
