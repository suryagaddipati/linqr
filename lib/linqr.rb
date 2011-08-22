require 'enumerable_provider'
require 'linqr_exp'
require 'ripper2ruby'
class Ruby::Node
  def visit(visitor)
    visitor.send("visit_#{self.class.name.split("::")[1].downcase}".to_sym, self)
  end
end

class Object
  def _(&proc_exp)
    LinqrExp.new(&proc_exp).evaluate
  end
end
