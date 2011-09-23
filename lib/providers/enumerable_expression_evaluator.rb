require 'ostruct'
require 'expression_evaluator_base'
class EnumerableExpessionEvaluator < ExpressionEvaluator

  def visit_group_by(node)
    node.expression.visit(self)
  end

  def visit_hash(node)
    record = OpenStruct.new
    node.elements.each do |e|
      key = e.key.visit(self)
      value = e.value.visit(self)
      record.send("#{key.to_s}=".to_sym,value)
    end
    record
  end

  def visit_argslist(node)
    node.map {|arg| arg.visit(self)}
  end

  def visit_array(node)
    node.elements.collect(&:arg).reduce([]){|out,n| out << variable_val(n) ; out}
  end

  def visit_binary(node)
    right_val = node.right.visit(self)
    left_val = node.left.visit(self)
    if node.operator.to_sym == :and
      left_val && right_val
    elsif node.operator.to_sym == :or
      left_val || right_val
    else
      left_val.send(node.operator.to_ruby.to_sym, right_val)
    end
  end

  def visit_call(node)
    target = node.target.visit(self)
    method_name = node.identifier ? node.identifier.to_sym : :[]
    if (node.arguments)
      arguments = node.arguments.collect { |x| x.visit(self) }
      target.send(method_name, *arguments)
    else
      target.send(method_name)
    end
  end
end

