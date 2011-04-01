require 'rdf' # @see http://rubygems.org/gems/rdf

module RDF
  module RDFObjects
    autoload :VERSION, File.dirname(__FILE__) + '/rdfobjects/version'
    autoload :AssertionSet, File.dirname(__FILE__) + '/rdfobjects/assertion_set'
    autoload :Graph, File.dirname(__FILE__) + '/rdfobjects/graph'
    autoload :ObjectSet, File.dirname(__FILE__) + '/rdfobjects/object_set'
    autoload :Resource, File.dirname(__FILE__) + '/rdfobjects/resource'
    autoload :Resource, File.dirname(__FILE__) + '/rdfobjects/resource'    
  end
  class URI
    include RDFObjects::Resource
    # Don't freeze the URIs.  Keep an eye on this, since, presumably, URIs are being frozen for a reason.
    # However, we cannot add graphs to frozen objects and the ObjectStore complicates things.
    def self.intern(str)
      (cache[str = str.to_s] ||= self.new(str))
    end      
  end
  
  class Node
    include RDFObjects::Resource
  end
    
  class Graph
    include RDFObjects::Graph
  end    
end # RDF