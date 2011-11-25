require 'expression_evaluator_base'
require_relative 'select_clause_evaluator'
class SqlProvider 
  def initialize(db,table)
    @table = table
    @db = db
  end
  def visit_arg(node)
    node.elements.first.visit(self)
  end

  def visit_binary(node)
   {node.left.identifier.to_sym  => node.right.visit(self)}
  end
  
  def visit_linqr_exp(exp)  
    table_alias = exp.from_clause.identifiers.first
    select_clause_evaluator = SelectClauseEvaluator.new(table_alias)
    exp.query_body.select_clause.visit(select_clause_evaluator)
    @db.query("select #{select_clause_evaluator.to_sql} from #{@table} as #{table_alias}")
  end

end

class DB
  def method_missing(m, *args, &block)  
   @table_name = m.to_s
   self
  end 
  def linqr_provider
    SqlProvider.new(self,@table_name)
  end
end
