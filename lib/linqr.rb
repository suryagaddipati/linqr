$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'providers/enumerable_provider'
require 'providers/mongodb/mongodb_provider'
require 'providers/hash_provider'
$:.unshift File.join(File.dirname(__FILE__),'..','third_party','ripper2ruby','lib')
require 'ripper2ruby'
class Object
  def _(&proc_exp)
    exp = Ripper::RubyBuilder.new(proc_exp)
    Thunk.new(exp)
  end

  class Thunk
    include Enumerable
    def initialize(exp)
      @exp = exp
    end
    def evaluate_expression
      @exp.parse
      linqr_exp = @exp.linqr_exp
      provider = linqr_exp.source.try(:linqr_provider)
      provider = MongoDbProvider.new(linqr_exp.source) if provider.nil?
      linqr_exp.visit(provider)
    end
    def each(&blk)
      evaluate_expression.each(&blk)
    end
  end
end
