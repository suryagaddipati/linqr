class  ActiveRecord::Base

  def evaluate_exp(linq_exp)

    debugger
  end


end


class EnumerableExpessionEvaluator
  def initialize(linq_exp)
    @binding = linq_exp.binding
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
    left_val.send(node.operator.to_ruby.to_sym, right_val)
  end

  def visit_statements(node)
    binary_exp = node.elements.first
    binary_exp.visit(self)
  end

end
