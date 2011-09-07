class Enumerator 

  def lazy_sort_by(&block)
    Enumerator.new do |yielder|
      index = 0
      sorted = sort_by(&block)
      loop do
        yielder.yield sorted[index]
        index += 1
        break if sorted.size == index
      end
    end
  end

  def lazy_select(&block)
    Enumerator.new do |yielder| 
      self.each do |val| 
        yielder.yield(val) if block.call(val) 
      end
    end
  end

  def lazy_map(&block)
    Enumerator.new do |yielder| 
      self.each do |value| 
        yielder.yield(block.call(value))
      end
    end
  end
end

