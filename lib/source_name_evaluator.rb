require 'ripper2ruby'
class SourceNameEvaluator
  def source_name_arg(node)
    node.name
  end

  def source_name_const(node)
    node.identifier.to_s
  end

  def source_name_variable(node)
    node.token.to_s
  end
end

class Ruby::Arg
  def name
    arg.name
  end
end
class Ruby::Call
  def name
    identifier.to_s
  end
end
class Ruby::Variable
  def name
    to_s
  end
end

class Ruby::Const
  def name
    identifier.to_s
  end
end
