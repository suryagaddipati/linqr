class ExpressionEvaluator

  def initialize(linq_exp)
    @binding = linq_exp.binding
  end

  def visit_variable(node)
    @binding.eval(node.to_s)
  end

  def visit_integer(node)
    node.value
  end

  def visit_float(node)
    node.value
  end
  def visit_unary(node)
    target = node.operand.visit(self)
    target.send("#{node.operator.to_s}@")
  end
  def visit_arg(node)
    node.arg.visit(self)
  end
  def visit_string(node)
    output = ""
    node.each do |e|
      output << e.visit(self)
    end
    output
  end
  
  def visit_stringcontent(node)
    node.to_s
  end

  def visit_statements(node)
    binary_exp = node.elements.first
    binary_exp.visit(self)
  end
end
