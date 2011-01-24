module RDF::RDFObjects
  module Resource
    attr_reader :graph
    def graph=(graph)
      @graph = graph
    end
    
    def assert(p, o)
      p = RDF::URI.new(p) unless p.is_a?(RDF::URI)
      unless o.is_a?(RDF::Resource) || o.is_a?(RDF::Literal)
        o = RDF::Literal.new(o)
      end
      @graph << [self, p, o]
    end
    
    def relate(p, o)
      o = RDF::Resource.new(o) unless o.is_a?(RDF::Resource)
      assert(p, o)
    end

    def [](p)
      results = {}
      if p.is_a?(RDF::Resource)
        @graph.query(:subject=>self, :predicate=>p).each do |r|
          if r.object.is_a?(RDF::Resource)
            r.object.extend(RDF::RDFObjects::Resource)
            r.object.graph = self.graph
          end
          results[r.predicate] ||=[]
          results[r.predicate] << r.object
        end          
      elsif p.is_a?(Class) && p.inspect =~ /^RDF::Vocabulary\(/
        regex = Regexp.new(p.to_s)
        if assertions
          assertions.each_pair do |pred, objects|
            results[pred.to_s] = objects if pred.to_s =~ /^#{regex}/
          end 
        end
        results.extend(AssertionSet)
        results.vocabulary = p
        results.subject = self
        
      elsif (RDF.const_defined?(p) && RDF.const_get(p).ancestors.index(RDF::Vocabulary))
        regex = Regexp.new(RDF.const_get(p).to_s)
        if assertions
          assertions.each_pair do |pred, objects|
            results[pred.to_s] = objects if pred.to_s =~ /^#{regex}/
          end 
        end
        results.extend(AssertionSet)
        results.vocabulary = RDF.const_get(p)         
        results.subject = self
      end
      
      if results.is_a?(AssertionSet)
        results.each_pair do |pred, objs|
          [*objs].each do |o|
            next unless o
            o.extend(ObjectSet)
            o.set_statement(Statement.new(self, pred, o))
          end
        end        
        obj_set = results
      else
        obj_set = case results.keys.length
        when 0
          set = []
          set.extend(ObjectSet)
          set.set_statement(Statement.new(self,p,""))
          set
        when 1
          set = []
          results.values.first.each do |v|
            set << v
          end
          set.extend(ObjectSet)
          set.set_statement(Statement.new(self,p,""))
          set
        end
      end
      obj_set
    end

    def []=(p,o)      
      p = RDF::URI.new(p) unless p.is_a?(RDF::URI)
      @graph.query(:subject=>self, :predicate=>p).each {|stmt| @graph.delete(stmt)}    
      [*o].each do |obj|
        next unless obj
        obj = cast_as_typed_object(obj)           
        @graph << [self, p, obj] unless obj.nil?
      end
    end
    
    def remove(p, o=nil)
      p = RDF::URI.new(p) unless p.is_a?(RDF::URI)
      if o
        o = cast_as_typed_object(o)
        @graph.query(:subject=>self, :predicate=>p, :object=>o).each {|stmt| @graph.delete(stmt)}
      else
        @graph.query(:subject=>self, :predicate=>p).each {|stmt| @graph.delete(stmt)}
      end
    end

    def push(p, o)
      p = RDF::URI.new(p) unless p.is_a?(RDF::URI)
      o = cast_as_typed_object(o)
      @graph << [self, p, o]
    end
    
    def cast_as_typed_object(o)
      return o if o.is_a?(RDF::Literal) || o.is_a?(RDF::Resource)
      return Literal.new(o)
    end
    
    def predicates
      p = []
      @graph.query(:subject=>self).each {|stmt| p << stmt.predicate unless p.index(stmt.predicate)}
      p
    end
    
    def properties
      results = {}
      @graph.query(:subject=>self).each do |r| 
        if r.object.is_a?(RDF::Resource)
          r.object.extend(RDF::RDFObjects::Resource)
          r.object.graph = self.graph
        end
        results[r.predicate] ||=[]
        results[r.predicate] << r.object
      end
      
      obj_set = case results.keys.length
      when 0 then nil
      else
        results.each_pair do |pred, objs|
          objs.each do |o|
            o.extend(ObjectSet)
            o.set_statement(Statement.new(self, pred, o))
          end
          #results[pred] = objs.first if objs.length == 1
          results
        end
      end
      obj_set      
    end
    alias :assertions :properties
    
    def type=(rdf_type)
      self[RDF.type] = rdf_type
    end
    
    def type
      self[RDF.type]
    end
    
    def clear
      @graph.query(:subject=>self).each {|stmt| @graph.delete(stmt)}
    end      
    
    def method_missing(meth, *args)
      if RDF.const_defined?(meth) && RDF.const_get(meth).ancestors.index(RDF::Vocabulary)
        send(:"[]", meth)
      end
    end

    def to_ntriples
      RDF::Writer.for(:ntriples).buffer do |writer|
        @graph.query(:subject=>self).each_statement do |statement|
          writer << statement
        end
      end      
    end
  end
end  