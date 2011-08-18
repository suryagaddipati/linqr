require 'sourcify'
require 'ripper'
require 'awesome_print'
require 'ripper2ruby'
class Object
  def _(&proc_exp)
    exp = Ripper::RubyBuilder.build(proc_exp.to_source)

    source_name = fcall(exp,"in_").select(Ruby::Arg).first.arg.token
    source = proc_exp.binding.eval(source_name)

    where_exp =  fexp(exp,"where")
    #assuming to be a binary expression
    filtered_values = source.select {|e| e.send(where_exp.operator.to_ruby.to_sym, where_exp.right.value)}

    
    select_exp =  fexp(exp,"select")
    #assuming to be a binary expression
    filtered_values.collect{|e| e.send(select_exp.operator.to_ruby.to_sym, select_exp.right.value) }

  end
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call| call.token == fname}.first
  end

  def fexp(exp, fname)
    f_arg = fcall(exp,fname).arguments.first
    f_arg.elements.first # make this less confusing
  end
end
