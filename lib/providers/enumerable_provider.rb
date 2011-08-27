require 'expression_evaluator_base'
GroupBy = Struct.new(:key,:values)
module  Enumerable

  def handle_hash(linq_exp)
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
  end

  def handle_where(linq_exp)
    return self unless linq_exp.where?
    self.select do|e| 
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.where.visit(EnumerableExpessionEvaluator.new(linq_exp))
    end
  end
  def handle_select(linq_exp,filtered_values)
    filtered_values.collect do |e|
      Object.send(:define_method,linq_exp.variable.to_sym) { e }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
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

  def evaluate_exp(linq_exp)
    if (self.is_a? Hash)
      handle_hash(linq_exp)
    else
      filtered_values = handle_where(linq_exp)
      if (linq_exp.group_by?)
        handle_group_by(linq_exp,filtered_values)
      else
        handle_select(linq_exp,filtered_values)
      end

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
    target.send(node.identifier.to_sym)
  end
end

class GroupByExpressionEvaluator < EnumerableExpessionEvaluator 
  attr_reader :grouping_var
  def visit_hash(node)
    @grouping_var = node.first.value.visit(self)
    node.first.key.visit(self)
  end
end
