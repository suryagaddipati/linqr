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
    target.nil? ? self.identifier.to_ruby : "#{target.to_ruby}.#{identifier.to_ruby}"
  end
end
class Ruby::Variable
  def name
    to_ruby
  end
end

class Ruby::Const
  def name
    identifier.to_ruby
  end
end
