class Linqr
  Scope = Struct.new(:expressions)
  Expression = Struct.new(:symbol, :args, :lineno, :proc, :scope)
  Output = Struct.new(:file, :expressions,:sel_var)

  VERSION = '0.2.0'

  METHODS_TO_KEEP = /^__/, /class/, /instance_/, /method_missing/, /object_id/, /define_singleton_method/

  instance_methods.each do |m|
    undef_method m unless METHODS_TO_KEEP.find { |r| r.match m }
  end
  undef_method :select

  def initialize(opts = {})
    @@remember_blocks_starting_with = Array(opts[:retain_blocks_for])
    @@only = Array(opts[:only])
    @@exclude = Array(opts[:except])
    @@output = Output.new
    @@file = nil
    @stack = []
  end

  def to_data(&block)
    instance_exec(&block)
    @@output.sel_var = @sel_var
    output
  end

  def output
    if @current_scope
      @@output.expressions = @current_scope.expressions
    end
    @@output
  end

  def file=(file)
    unless @@file
      @@file = file
      @@output.file = @@file
    end
  end

  def method_missing(sym, *args, &block)
    unless @sel_var
      @sel_var = Linqr.new
      define_singleton_method (sym) {@sel_var}
    end

    caller[0] =~ (/(.*):(.*):in?/)
    file, lineno = $1, $2
    self.file = file

    if !@@only.empty? && !@@only.include?(sym)
      fail(NoMethodError, sym.to_s)
    end
    if !@@exclude.empty? && @@exclude.include?(sym)
      fail(NoMethodError, sym.to_s)
    end

    args = (args.length == 1 ? args.first : args)
    @current_scope ||= Scope.new([])
    @current_scope.expressions << Expression.new(sym, args, lineno)
    if block
      if @@remember_blocks_starting_with.include? sym
        @current_scope.expressions.last.proc = block
      else
        nest(&block)
      end
    end
  end
private
  def nest(&block)
    @stack.push @current_scope
    new_scope = Scope.new([])
    @current_scope.expressions.last.scope = new_scope
    @current_scope = new_scope
    instance_exec(&block)
    @current_scope = @stack.pop
  end
end

class Object
  def _(&block)
     output = Linqr.new(:retain_blocks_for => [:where, :select]).to_data(&block)
     enumerable  = output.expressions.select{|e| e.symbol == :in_}.first.args
     sel_var = output.sel_var.output
     filter = sel_var.expressions.first
     selector =sel_var.expressions[1]
     enumerable.select{|x| x.send(filter.symbol,filter.args) == true}.collect{|x| x.send(selector.symbol,selector.args)}
  end
end