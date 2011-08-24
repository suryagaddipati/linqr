require 'active_record'
require 'providers/enumerable_provider'
class ActiveRecord::Base

  def evaluate_exp(linq_exp)
    #raise "Not an active-record class" if self.table_name
    evaluator = ActiveRecordExpressionEvaluator.new(linq_exp)
    linq_exp.where.visit(evaluator)
    selected_values = self.class.find(:all, :conditions => evaluator.conditions)
    selected_values.collect do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end
end


class ActiveRecordExpressionEvaluator
  attr_reader :conditions
  def initialize(linq_exp)
    @binding = linq_exp.binding
    @conditions = {}
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
    node.identifier.to_s.to_sym
  end

  def visit_statements(node)
    binary_exp = node.elements.first
    binary_exp.visit(self)
  end

end
