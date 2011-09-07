$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'providers/enumerable_provider'
require 'providers/hash_provider'
require 'providers/active_record/activerecord_provider'
require 'providers/groupon/groupon_provider'
require 'linqr_exp'
require 'ripper2ruby'
class Ruby::Node
  def visit(visitor)
    class_name=self.class.name.split('::').size == 2 ? self.class.name.split('::')[1]: self.class.name
    visitor.send("visit_#{class_name.downcase}".to_sym, self)
  end
  def evaluate_source_name(visitor)
    visitor.send("source_name_#{self.class.name.split('::')[1].downcase}".to_sym, self)
  end
  def to_sym
    to_ruby.to_sym
  end
end


class OrderBy
  def initialize(node)
    @node = node
  end

  def expressions
    descending?? (@node.arguments[0...-1] << last_arg.first.key): @node.arguments
  end

  def descending?
    last_arg.is_a? Ruby::Hash
  end

  def last_arg
    @node.arguments.last.arg
  end
end

class GroupBy < Ruby::Node
  def initialize(node)
    @node = node
  end
  def expression
    return @node.arg.first.key if @node.arg.is_a? Ruby::Hash
    @node
  end
  def grouping_var
    @node.arg.first.value.first.to_sym
  end
end

class Object
  def _(&proc_exp)
    LinqrExp.new(proc_exp).evaluate
  end
end
