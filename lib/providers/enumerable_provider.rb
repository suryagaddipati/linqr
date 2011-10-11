require 'providers/enumerable_expression_evaluator'
require 'lazy_enumerator'
require 'group_by'
class EnumerableProvider < EnumerableExpessionEvaluator

  def handle_order_by(linq_exp,filtered_values)
    order_by = linq_exp.query_body.order_by_clause
    filtered_values = filtered_values.to_enum #huh?
    order_by.expressions.reduce(filtered_values) do |values, sort_exp|
      values.lazy_sort_by do|e| 
        define_var(linq_exp.from_clause.identifiers.first,e)
        sort_val = sort_exp.visit(self)
        order_by.descending?? 1 - sort_val : sort_val
      end
    end
  end

  def handle_group_by(exp,filtered_values)
    group_by = exp.query_body.group_by_clause
    grouped_values = filtered_values.group_by do |e|
      define_var(exp.from_clause.identifiers.first,e)
      group_by.visit(self)
    end

    grouped_values.collect do |(k,v)|
      define_var(group_by.grouping_var.to_sym, Grouped.new(k,v) )
    exp.query_body.select_clause.visit(self)
    end
  end


  def define_var(var_name,val)
    @variables ||= {}
    @variables[var_name] = val
  end
  def variable_val(name)
    @variables[name.to_sym]  || @exp.variable_val(name)
  end

  def eval_from_clauses(from_clauses,exp,out)
    from_clause = from_clauses.first
    src = variable_val(from_clause.expression)
    src.each do |e|
      define_var(from_clause.identifiers.first,e)
      if(from_clauses.count == 1)
          evaluate_where(exp,out,e)
      else
        eval_from_clauses(from_clauses[1..-1],exp,out)
      end
    end
  end
  


def eval_join_clauses(join_clauses,exp,out)
    join_clause = join_clauses.first
    src = variable_val(join_clause.expression)
    src.each do |e|
      define_var(join_clause.identifiers.first,e)
      if(join_clauses.count == 1 )
          evaluate_where(exp,out,e)  if(join_clause.on_clause.visit(self))
      else
        eval_join_clauses(join_clauses[1..-1],exp,out)
      end
    end
end

  def visit_linqr_exp(exp)
    @exp = exp
    from_clause = exp.from_clause
    source = exp.source
    out = []
    source.each do |e|
      define_var(from_clause.identifiers.first,e)
      if(exp.query_body.from_clauses)
        eval_from_clauses(exp.query_body.from_clauses,exp,out)
      else
        if(exp.query_body.join_clauses)
          eval_join_clauses(exp.query_body.join_clauses,exp,out)
        else
          evaluate_where(exp,out,e)
        end
      end

    end

    out = exp.query_body.group_by_clause ? handle_group_by(exp,out):out 
    exp.query_body.order_by_clause ? handle_order_by(exp,out) : out
  end

  def visit_where_clause(where_clause)
    where_clause.expression.visit(self)
  end

  def evaluate_where(exp,out,e)
    if exp.query_body.where_clause
      if exp.query_body.where_clause.visit(self)
        out << (exp.query_body.group_by_clause ? e :  exp.query_body.select_clause.visit(self))
      end
    else
      out << exp.query_body.select_clause.visit(self)
    end
  end
end


module  Enumerable
  def linqr_provider
    EnumerableProvider.new(self)
  end
end
