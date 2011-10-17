class MongoDbProvider
  def initialize(mongo_class)
    @model_class = mongo_class
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
