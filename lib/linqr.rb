$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'providers/enumerable_provider'
require 'providers/hash_provider'
require 'linqr_exp'

class Object
  def _(&proc_exp)
    LinqrExp.new(proc_exp).evaluate
  end
end
