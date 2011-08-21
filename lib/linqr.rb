require 'sourcify'
require 'ripper'
require 'awesome_print'
require 'ripper2ruby'
class Ruby::Variable
  def exp_value(binding)
    binding.eval(self.to_s)
  end
end
class Ruby::Integer
  def exp_value(binding)
   self.value
  end
end
class Ruby::Statements
  def exp_value(binding)
    binary_exp = elements.first
    right_val = binary_exp.right.exp_value(binding)
    left_val = binary_exp.left.exp_value(binding)
    left_val.send(binary_exp.operator.to_ruby.to_sym, right_val)
  end
end

class Object
  def _(&proc_exp)
    @binding = proc_exp.binding
    exp = Ripper::RubyBuilder.build(proc_exp.to_source)
    source_name = fcall(exp,"in_").select(Ruby::Arg).first.arg.token
    source = @binding.eval(source_name)

    variable = fcall(exp,"from").arguments.first.arg.to_s
    
    where_exp =  fexp(exp,"where")
    #assuming to be a binary expression
    filtered_values = source.select do|e| 
      Object.send(:define_method,variable.to_sym) { e }
      left_val = evaluate(where_exp.left)
      right_val = evaluate(where_exp.right)
      left_val.send(where_exp.operator.to_ruby.to_sym, right_val)
    end

    
    select_exp =  fexp(exp,"select")
    #assuming to be a binary expression
    filtered_values.collect{|e| e.send(select_exp.operator.to_ruby.to_sym, select_exp.right.value) }

  end

  def evaluate(exp)
    exp.exp_value(@binding)
  end
  
  def fcall(exp, fname)
    exp.select(Ruby::Call).select {|call| call.token == fname}.first
  end

  def fexp(exp, fname)
    f_arg = fcall(exp,fname).arguments.first
    f_arg.elements.first # make this less confusing
  end
end
