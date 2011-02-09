module RDF::RDFObjects   
  module ObjectSet
    attr_reader :subject, :predicate
    def <<(o)
      [*o].each do |object|
        next unless object
        @subject.push(@predicate, object)
      end
      self.replace(@subject[@predicate])
    end
    
    def set_statement(stmt)
      @subject = stmt.subject
      @predicate = stmt.predicate
    end
    def clear
      @subject[@predicate]=nil
      super
    end
    def concat(ary)
      ary.each do |i|
        @subject.push(@predicate, i)
      end
      super(ary)
    end
    
    def delete(o)
      d = super(o)
      @subject.remove(@predicate, o)
      d
    end
    
    def delete_at(i)
      d = super(i)
      @subject.remove(@predicate, d) if d
      d
    end
        
    def fill(*args)
      super(args)
      @subject[@predicate]=self
      @subject[@predicate]
    end
    def replace(ary)
      @subject[@predicate]=ary
      super(ary)  
    end  
    
    def insert(index, *obj)
      super(index, obj)
      @subject[@predicate]=self
      self
    end
    
    def pop(n=nil)
      p = super(n)
      [*p].each do |obj|
        @subject.remove(@predicate, obj) if obj
      end
      self
    end
    
    # def push(*obj)
    #   super(obj)
    #   @subject[@predicate] = self
    #   self
    # end
    
    def reverse!
      super
      @subject[@predicate] = self
      self
    end
    
    def rotate!(cnt=1)
      super(cnt)
      @subject[@predicate] = self
      self
    end      
    
    def shift(n=nil)
      s = super(n)
      @subject[@predicate] = self
      s
    end
    
    def shuffle!
      super
      @subject[@predicate] = self
      self
    end      
    
    def sort!
      super
      @subject[@predicate] = self
      self
    end
    
    def unshift(*obj)
      super(obj)                  
      @subject[@predicate] = self
      self
    end      
  end
end