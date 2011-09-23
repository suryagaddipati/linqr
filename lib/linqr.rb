$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'providers/enumerable_provider'
require 'providers/hash_provider'
$:.unshift File.join(File.dirname(__FILE__),'..','third_party','ripper2ruby','lib')
require 'ripper2ruby'
class Object
  def _(&proc_exp)
    exp = Ripper::RubyBuilder.new(proc_exp)
    exp.parse
    linqr_exp = exp.linqr_exp
    provider = linqr_exp.source.linqr_provider
    linqr_exp.visit(provider)
    #provider.evaluate(linqr_exp)
  end
end
