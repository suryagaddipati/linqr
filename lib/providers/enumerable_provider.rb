require 'expression_evaluator_base'
require 'group_by'
module  Enumerable
  def handle_where(linq_exp)
    if (self.is_a? Hash)
      filtered_values = self.select do|k,v| 
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else
      self.select do|e| 
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end
  end
  def handle_order_by(linq_exp,filtered_values)
    filtered_values.sort_by do|e| 
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.order_by.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end
  def handle_group_by(linq_exp,filtered_values)
    group_by_evaluator = GroupByExpressionEvaluator.new(linq_exp)
    grouped_values = filtered_values.group_by do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.group_by.visit(group_by_evaluator)
    end

    grouped_values.collect do |(k,v)|
      Object.send(:define_method,group_by_evaluator.grouping_var) { GroupBy.new(k,v) }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end

  def handle_select(linq_exp,filtered_values)
    if (self.is_a? Hash)
      filtered_values.collect do |k,v|
        Object.send(:define_method,linq_exp.variables[0].to_sym) { k }
        Object.send(:define_method,linq_exp.variables[1].to_sym) { v }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else
      filtered_values.collect do |e|
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end
  end


  def linqr_provider
    self
  end

  def evaluate (linq_exp)
    provider = self.linqr_provider
    filtered_values =linq_exp.where?? provider.handle_where(linq_exp) : self
    filtered_values = linq_exp.order_by?? provider.handle_order_by(linq_exp,filtered_values) : filtered_values
    if (linq_exp.group_by?)
      provider.handle_group_by(linq_exp,filtered_values)
    else
      provider.handle_select(linq_exp,filtered_values)
    end
  end

end


require 'ostruct'
class EnumerableExpessionEvaluator < ExpressionEvaluator
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
    method_name = node.identifier ? node.identifier.to_sym : :[]
    if (node.arguments)
      arguments = node.arguments.collect { |x| x.visit(self) }
      target.send(method_name, *arguments)
    else
      target.send(method_name)
    end
  end
end

class GroupByExpressionEvaluator < EnumerableExpessionEvaluator 
  attr_reader :grouping_var
  def visit_hash(node)
    @grouping_var = node.first.value.visit(self)
    node.first.key.visit(self)
  end
end
