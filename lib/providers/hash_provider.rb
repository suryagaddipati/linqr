require 'providers/enumerable_provider'

class HashProvider < EnumerableProvider
  def evaluate (exp)
    evaluator = EnumerableExpessionEvaluator.new(self)
    from_clause = exp.from_clause
    source = exp.source
    out = []
    source.each do |k,v|
      define_var(from_clause.identifiers.first,k)
      define_var(from_clause.identifiers[1],v)
      out << exp.query_body.select_clause.visit(evaluator) if exp.query_body.where_clause.visit(evaluator)
    end

    out
  end


end

class  Hash
  def linqr_provider
    HashProvider.new(self)
  end
end
