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
  def select
    fexp(@exp,"select")
  end
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call| call.token == fname}.first
  end

  def fexp(exp, fname)
    f_arg = fcall(exp,fname).arguments.first
    f_arg.elements.first # make this less confusing
  end
  def source
    source_name = fcall(@exp,"in_").select(Ruby::Arg).first.arg.token
    @binding.eval(source_name)
  end
end
