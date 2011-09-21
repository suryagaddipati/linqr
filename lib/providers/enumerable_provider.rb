require 'providers/enumerable_expression_evaluator'
require 'lazy_enumerator'
require 'group_by'
class EnumerableProvider

  attr_reader :variables
  def handle_order_by(linq_exp,filtered_values)
    order_by = linq_exp.order_by
    order_by.expressions.reduce(filtered_values) do |values, sort_exp|
      values.lazy_sort_by(&linq_exp.with_vars do|e| 
        sort_val = sort_exp.visit(EnumerableExpessionEvaluator.new(linq_exp))
        order_by.descending?? 1 - sort_val : sort_val
      end)
    end
  end

  def handle_group_by(exp,filtered_values)
    evaluator = EnumerableExpessionEvaluator.new(self)
    group_by = exp.query_body.group_by_clause
    grouped_values = filtered_values.group_by do |e|
      define_var(exp.from_clause.identifiers.first,e)
      group_by.visit(evaluator)
    end

    grouped_values.collect do |(k,v)|
      define_var(group_by.grouping_var.to_sym, Grouped.new(k,v) )
    exp.query_body.select_clause.visit(evaluator)
    end
  end


  def define_var(var_name,val)
    @variables ||= {}
    @variables[var_name] = val
  end
  def variable_val(name)
    @variables[name.to_sym]
  end
  def evaluate (exp)
    evaluator = EnumerableExpessionEvaluator.new(self)
    from_clause = exp.from_clause
    source = exp.source
    out = []
    source.each do |e|
      define_var(from_clause.identifiers.first,e)
      if exp.query_body.where_clause.visit(evaluator)
        out << (exp.query_body.group_by_clause ? e :  exp.query_body.select_clause.visit(evaluator))
      end
    end

    exp.query_body.group_by_clause ? handle_group_by(exp,out):out 
  end
end
module  Enumerable
  def linqr_provider
    EnumerableProvider.new(self)
  end
end
