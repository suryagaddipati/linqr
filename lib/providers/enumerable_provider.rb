require 'expression_evaluator_base'
module  Enumerable

  def evaluate_exp(linq_exp)
    if (self.is_a? Hash)
      filtered_values = self.select do|k,v| 
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end

      filtered_values.collect do |k,v|
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end

    else
      filtered_values = self.select do|e| 
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end

      filtered_values.collect do |e|
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end

  end
end


require 'ostruct'
class EnumerableExpessionEvaluator < ExpressionEvaluator
  def visit_symbol(node)
    node.value
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
    target.send(node.identifier.to_sym)
  end

end
