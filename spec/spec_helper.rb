class Object
  # alias_method :try, :__send__
  def try(method, *args, &block)
    send(method, *args, &block) if respond_to?(method)
  end
  def __(&block)
    _(&block).to_a
  end
end
