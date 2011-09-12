require 'sourcify'
$:.unshift File.join(File.dirname(__FILE__),'..','third_party','ripper2ruby','lib')
require 'ripper2ruby'
class LinqrExp
  attr_reader :binding
  def initialize(proc_exp)
    @exp = Ripper::RubyBuilder.build(proc_exp.to_source)
    @linqr_exp = Ripper::RubyBuilder.linqr_exp
    @binding = proc_exp.binding
  end
 %w(where from select).each do | q |
   send(:define_method,q.to_sym) { fexp(q) }
   send(:define_method,(q+"?").to_sym) {!fcall(q).nil?}
 end

 def with_vars
   @variables ||= {}
   Proc.new do |args|
     args= [args] unless args.is_a? Array
     args.each_with_index do |param, idx|
       @variables[variables[idx].to_s]= param
     end
     yield *args
   end
 end

 def set_variable(var,val)
   @variables ||= {}
   @variables[var] = val
 end

 def variable_val(var_name)
   if (@variables && var = @variables[var_name])
     var
   else
    @binding.eval(var_name)
   end
 end

 def group_by
   @exp.select(Ruby::Linqr::GroupBy).first
 end

 def group_by?
   @exp.select(Ruby::Linqr::GroupBy).length > 0 
 end

 def order_by
   @exp.select(Ruby::Linqr::OrderBy).first
 end

 def order_by?
   @exp.select(Ruby::Linqr::OrderBy).length > 0 
 end

  def evaluate 
    source.linqr_provider.evaluate(self)
  end

  def variable
    variables.first
  end
  def variables
    @linqr_exp.from_clause.from_generators.first.identifiers
  end
  def fcall(fname)
    fcalls(fname).first
  end

  def fcalls(fname)
    @exp.select(Ruby::Call).select {|call|call.identifier &&  call.token == fname}
  end

  def fexp(fname)
    fcall(fname).arguments.first
  end

  def source
    source_name = @linqr_exp.from_clause.from_generators.first.expression
    @binding.eval(source_name)
    #sources.last
  end
end
