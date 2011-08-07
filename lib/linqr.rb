class Linqr
  Scope = Struct.new(:expressions)
  Expression = Struct.new(:symbol, :args, :lineno, :proc, :scope)
  Output = Struct.new(:file, :expressions)

  VERSION = '0.2.0'

  METHODS_TO_KEEP = /^__/, /class/, /instance_/, /method_missing/, /object_id/

  instance_methods.each do |m|
    undef_method m unless METHODS_TO_KEEP.find { |r| r.match m }
  end

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
      # there is some simpler recursive way of doing this, will fix it shortly
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
     output = Linqr.new(:retain_blocks_for => [:where, :selectr]).to_data(&block)
     enumerable  = output.expressions.select{|e| e.symbol == :from}.first.args
     filter =   output.expressions.select{|e| e.symbol == :where}.first.proc
     selector = output.expressions.select{|e| e.symbol == :selectr}.first.proc
     enumerable.select(&filter).collect(&selector)
  end
end
