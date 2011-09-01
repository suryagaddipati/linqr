require 'sourcify'
require 'ripper'
class LinqrExp

 %w(where group_by from select order_by).each do | q |
   send(:define_method,q.to_sym) { fexp(@exp,q) }
   send(:define_method,(q+"?").to_sym) {!fcall(@exp,q).nil?}
 end


  attr_reader :binding
  def initialize(&proc_exp)
    @exp = Ripper::RubyBuilder.build(proc_exp.to_source)
    @binding = proc_exp.binding
  end

  def evaluate 
    source.evaluate(self)
  end

  def variable
    variables.first
  end
  def variables
    fcall(@exp,"from").arguments.collect{|a|a.arg.to_s}
  end
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call|call.identifier &&  call.token == fname}.first
  end


  def fexp(exp, fname)
    f_arg = fcall(exp,fname).arguments.first
    f_arg # make this less confusing
  end
  def source
    token = fcall(@exp,"in_").select(Ruby::Arg).first.arg
    source_name = token.evaluate_source(self)
    @binding.eval(source_name)
  end


  def source_name_const(node)
    node.identifier.to_s
  end
  def source_name_variable(node)
    node.token.to_s
  end
end
