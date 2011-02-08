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
  end      
end