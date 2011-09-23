require 'providers/enumerable_provider'

class HashProvider < EnumerableProvider
  def visit_linqr_exp (exp)
    from_clause = exp.from_clause
    source = exp.source
    out = []
    source.each do |k,v|
      define_var(from_clause.identifiers.first,k)
      define_var(from_clause.identifiers[1],v)
      out << exp.query_body.select_clause.visit(self) if exp.query_body.where_clause.visit(self)
    end

    out
  end


end

class  Hash
  def linqr_provider
    HashProvider.new(self)
  end
end
