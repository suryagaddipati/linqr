require 'active_record'
require 'group_by'
require 'providers/enumerable_provider'
require 'providers/active_record/active_record_expression_evaluator'
class ActiveRecordProvider
  def initialize(active_record_class)
    @active_record_class = active_record_class
  end
  def evaluate(linq_exp)
    query_params = {}
    evaluator = ActiveRecordExpressionEvaluator.new(linq_exp)
    if (linq_exp.where?)
      linq_exp.where.visit(evaluator)
      query_params.merge!(:conditions =>evaluator.conditions)
    end

    group_by_evaluator = ArGroupByExpressionEvaluator.new(linq_exp)
    if(linq_exp.group_by?)
      query_params.merge!(:group =>linq_exp.group_by.visit(group_by_evaluator))
    end
    if(linq_exp.order_by?)
      query_params.merge!(:order =>linq_exp.order_by.visit(evaluator))
    end

    selected_values = @active_record_class.find(:all,query_params)

    if (linq_exp.group_by?)
      grouped_values = selected_values.group_by(&group_by_evaluator.group_by)
      grouped_values.collect do |(k,v)|
        Object.send(:define_method,group_by_evaluator.grouping_var) { GroupBy.new(k,v) }
      linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    else 
      selected_values.collect do |e|
        Object.send(:define_method,linq_exp.variable.to_sym) { e }
        linq_exp.select.visit(EnumerableExpessionEvaluator.new(linq_exp))
      end
    end
  end
end

class ActiveRecord::Base
  def self.linqr_provider
    ActiveRecordProvider.new(self)
  end
end


