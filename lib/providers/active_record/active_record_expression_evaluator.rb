require 'expression_evaluator_base'
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
