module RDF::RDFObjects
  module Graph
    def create(*args, &block)      
      r = RDF::Resource.new(args.shift, *args, &block)
      r.graph = self
      r
    end
    
    def [](id)
      id = RDF::Resource.new(id) unless id.is_a?(Resource)
      r = self.first_subject(:subject=>id)
      r = self.first_object(:object=>id) unless r
      r.graph = self if r
      r
    end
    
    def to_ntriples
      RDF::Writer.for(:ntriples).buffer do |writer|
        self.each_statement do |statement|
          writer << statement
        end
      end
    end
    
    def <<(data)
      case data
      when RDF::RDFObjects::Resource
        data.statements.each do |stmt|
          self.insert(stmt)
        end
      else
        super(data)
      end
    end
 
    def insert_statement(statement)
      statement = statement.dup
      statement.context = context
      statement.each_triple.each do |s,p,o|
        puts s.to_s
        s.graph = self if s.is_a?(RDF::Resource)
      end      
      @data.insert(statement)
    end    
  end      
end

module RDF
  class Graph
    def insert_statement(statement)
      statement = statement.dup
      statement.context = context
      statement.to_triple.each_cons(3) do |s,p,o|
        s.graph = self
        o.graph = self if o.is_a?(RDF::Resource) && !o.frozen?
      end      
      @data.insert(statement)
    end      
  end
end


