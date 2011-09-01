require 'groupon'
require 'expression_evaluator_base'
class GrouponDeals

  def self.evaluate(linq_exp)
    Groupon.api_key = '966a0273f2974c725e25d507d4e07daabcb0ee00'
    evaluator = GrouponExpressionEvaluator.new(linq_exp)
    linq_exp.where.visit(evaluator)
    selected_values = Groupon.deals(evaluator.conditions)
    #puts evaluator.conditions.inspect
    selected_values.collect do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end
end


class GrouponExpressionEvaluator < ExpressionEvaluator
  attr_reader :conditions
  def initialize(linq_exp)
    @conditions = {}
    super
  end

  def visit_binary(node)
    right_val = node.right.visit(self)
    left_val = node.left.visit(self)
    @conditions[left_val] = right_val
  end


  def visit_call(node)
    node.identifier.to_s.to_sym
  end


end
