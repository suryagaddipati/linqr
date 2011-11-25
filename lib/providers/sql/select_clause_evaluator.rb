class SelectClauseEvaluator
 def initialize(table_alias)
 @columns = []
 @table_alias = table_alias.to_s
 end
 def visit_arg(node)
   if (node.to_ruby == @table_alias)
     @columns << "#{@table_alias}.*"
   else
     @columns << node.to_ruby
   end
 end
 def to_sql
   @columns.join(', ')
 end
end
