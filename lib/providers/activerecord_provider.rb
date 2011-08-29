require 'active_record'
require 'group_by'
require 'providers/enumerable_provider'
require 'expression_evaluator_base'
class ActiveRecord::Base

  def self.evaluate_exp(linq_exp)
    #raise "Not an active-record class" if self.table_name
    query_params = {}
    evaluator = ActiveRecordExpressionEvaluator.new(linq_exp)
    if (linq_exp.where?)
      linq_exp.where.visit(evaluator)
      query_params.merge!(:conditions =>evaluator.conditions)
    end

    group_by_evaluator = ArGroupByExpressionEvaluator.new(linq_exp)
    if(linq_exp.group_by?)
      query_params.merge!(:group =>linq_exp.group_by.visit(group_by_evaluator))
    end
    if(linq_exp.order_by?)
      query_params.merge!(:order =>linq_exp.order_by.visit(evaluator))
    end

    selected_values = self.find(:all,query_params)

    if (linq_exp.group_by?)
      grouped_values = selected_values.group_by(&group_by_evaluator.group_by)
      grouped_values.collect do |(k,v)|
        Object.send(:define_method,group_by_evaluator.grouping_var) { GroupBy.new(k,v) }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else 
      selected_values.collect do |e|
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end
  end
end


class ActiveRecordExpressionEvaluator < ExpressionEvaluator
  attr_reader :conditions
  def initialize(linq_exp)
    @binding = linq_exp.binding
    @conditions = {}
  end

  def visit_argslist(node)
    node.first.visit(self)
  end
  def visit_variable(node)
    @binding.eval(node.to_s)
  end

  def visit_integer(node)
    node.value
  end

  def visit_binary(node)
    right_val = node.right.visit(self)
    left_val = node.left.visit(self)
    @conditions[left_val] = right_val
  end

  def visit_arg(node)
    node.arg.visit(self)
  end
  def visit_string(node)
    node.value
  end

  def visit_call(node)
    call = node.identifier.to_sym
    return call unless call == :member?
    target = node.target.visit(self)
    argument = node.arguments.visit(self)
    @conditions[argument] = target
  end
  def visit_array(node)
    node.value
  end

  def visit_statements(node)
    binary_exp = node.elements.first
    binary_exp.visit(self)
  end

end

class ArGroupByExpressionEvaluator < ActiveRecordExpressionEvaluator
  attr_reader :grouping_var , :group_by
  def visit_hash(node)
    @grouping_var = node.first.value.visit(self)
    @group_by = node.first.key.visit(self)
    @group_by
  end
end
