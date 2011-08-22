module  Enumerable

  def evaluate_exp(linq_exp)
    #assuming to be a binary expression
    filtered_values = self.select do|e| 
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end

    #assuming to be a binary expression
    filtered_values.collect{|e| e.send(linq_exp.select.operator.to_ruby.to_sym, linq_exp.select.right.value) }
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
