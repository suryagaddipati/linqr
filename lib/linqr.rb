require 'providers/enumerable_provider'
require 'providers/activerecord_provider'
require 'providers/groupon_provider'
require 'linqr_exp'
require 'ripper2ruby'
class Ruby::Node
  def visit(visitor)
    visitor.send("visit_#{self.class.name.split("::")[1].downcase}".to_sym, self)
  end
  def evaluate_source(visitor)
    visitor.send("source_name_#{self.class.name.split("::")[1].downcase}".to_sym, self)
  end
  def to_sym
    to_ruby.to_sym
  end
end

class Object
  def _(&proc_exp)
    LinqrExp.new(&proc_exp).evaluate
  end
end
