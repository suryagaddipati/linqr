require 'sourcify'
require 'ripper'
class LinqrExp
  attr_reader :binding
  def initialize(&proc_exp)
    @exp = Ripper::RubyBuilder.build(proc_exp.to_source)
    @binding = proc_exp.binding
  end
  def evaluate 
    source.evaluate_exp(self)
  end
  def where
    fexp(@exp,"where")
  end
  def variable
      fcall(@exp,"from").arguments.first.arg.to_s
  end
  def variables
    fcall(@exp,"from").arguments.collect{|a|a.arg.to_s}
  end
  def select
    fexp(@exp,"select")
  end
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call| call.token == fname}.first
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
