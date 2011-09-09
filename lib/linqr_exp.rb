require 'sourcify'
require 'ripper'
require 'source_name_evaluator'
class LinqrExp

 %w(where from select).each do | q |
   send(:define_method,q.to_sym) { fexp(@exp,q) }
   send(:define_method,(q+"?").to_sym) {!fcall(@exp,q).nil?}
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
   GroupBy.new(fexp(@exp,"group_by")) 
 end

 def group_by?
   !fcall(@exp,"group_by").nil?
 end

 def order_by
   OrderBy.new(fcall(@exp,"order_by")) 
 end

 def order_by?
   !fcall(@exp,"order_by").nil?
 end


  attr_reader :binding
  def initialize(proc_exp)
    @exp = Ripper::RubyBuilder.build(proc_exp.to_source)
    @binding = proc_exp.binding
  end

  def evaluate 
    source.linqr_provider.evaluate(self)
  end

  def variable
    variables.first
  end
  def variables
    fcall(@exp,"from").arguments.collect(&:name)
  end
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call|call.identifier &&  call.token == fname}.first
  end


  def fexp(exp, fname)
    f_arg = fcall(exp,fname).arguments.first
    f_arg # make this less confusing
  end
  def source
    token =fcall(@exp,"in_").arguments.first
    source_name = token.evaluate_source_name(SourceNameEvaluator.new)
    @binding.eval(source_name)
  end


end
