require 'core_ext/object/meta_class'
require 'core_ext/object/try'
require 'ruby/node/composite'
require 'ruby/node/source'
require 'ruby/node/traversal'
require 'ruby/node/conversions'

module Ruby
  class Node
    include Comparable
    include Composite
    include Source
    include Traversal
    include Conversions
   
    ##addons 
    def visit(visitor)
      class_name=self.class.name.split('::').size  > 1? self.class.name.split('::').last : self.class.name
      visitor.send("visit_#{class_name.downcase}".to_sym, self)
    end
    def evaluate_source_name(visitor)
      visitor.send("source_name_#{self.class.name.split('::')[1].downcase}".to_sym, self)
    end
    def to_sym
      to_ruby.to_sym
    end
    ##end  
    
    def row
      position[0]
    end

    def column
      position[1]
    end

    def length(prolog = false)
      to_ruby(prolog).length
    end
    
    def nodes
      []
    end
    
    def all_nodes
      nodes + nodes.map { |node| node.all_nodes }.flatten
    end
    
    def <=>(other)
      position <=> (other.respond_to?(:position) ? other.position : other)
    end
    
    protected
      def update_positions(row, column, offset_column)
        pos = self.position
        pos.col += offset_column if pos && self.row == row && self.column > column
        nodes.each { |c| c.send(:update_positions, row, column, offset_column) }
      end
  end
end
