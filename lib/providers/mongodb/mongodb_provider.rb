require 'expression_evaluator_base'
class MongoDbProvider < ExpressionEvaluator
  def initialize(mongo_class)
    @model_class = mongo_class
  end
  def visit_arg(node)
    node.elements.first.visit(self)
  end

  def visit_binary(node)
   {node.left.identifier.to_sym  => node.right.visit(self)}
  end
  
  def visit_linqr_exp(exp)
    if (exp.query_body.where_clause)
      where_criteria = exp.query_body.where_clause.expression.visit(self)
      @model_class.where(where_criteria)
    else
      @model_class.all
    end
  end

end
