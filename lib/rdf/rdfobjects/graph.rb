module RDF::RDFObjects
  module Graph
    def create(*args)
      r = RDF::Resource.new(args)
      r.graph = self
      r
    end
    
    def [](id)
      id = RDF::Resource.new(id) unless id.is_a?(Resource)
      r = self.first_subject(:subject=>id)
      r = self.first_object(:object=>id) unless r
      r.graph = self
      r
    end
    
    def to_ntriples
      RDF::Writer.for(:ntriples).buffer do |writer|
        self.each_statement do |statement|
          writer << statement
        end
      end
    end
  end      
end