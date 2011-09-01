require 'providers/enumerable_expression_evaluator'
require 'group_by'
class EnumerableProvider
  def initialize(enumerable)
    @enumerable = enumerable
  end
  def handle_where(linq_exp)
    if (@enumerable.is_a? Hash)
      filtered_values = @enumerable.select do|k,v| 
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else
      @enumerable.select do|e| 
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end
  end
  def handle_order_by(linq_exp,filtered_values)
    filtered_values.sort_by do|e| 
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.order_by.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end
  def handle_group_by(linq_exp,filtered_values)
    group_by_evaluator = GroupByExpressionEvaluator.new(linq_exp)
    grouped_values = filtered_values.group_by do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.group_by.visit(group_by_evaluator)
    end

    grouped_values.collect do |(k,v)|
      Object.send(:define_method,group_by_evaluator.grouping_var) { GroupBy.new(k,v) }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

  def handle_select(linq_exp,filtered_values)
    if (@enumerable.is_a? Hash)
      filtered_values.collect do |k,v|
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else
      filtered_values.collect do |e|
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
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

