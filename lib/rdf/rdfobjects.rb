require 'rdf' # @see http://rubygems.org/gems/rdf

module RDF
  module RDFObjects
    autoload :VERSION, 'rdf/rdfobjects/version'
    autoload :AssertionSet, 'rdf/rdfobjects/assertion_set'
    autoload :Graph, 'rdf/rdfobjects/graph'
    autoload :ObjectSet, 'rdf/rdfobjects/object_set'
    autoload :Resource, 'rdf/rdfobjects/resource'
  end
  class URI
    include RDFObjects::Resource
  end
  
  class Node
    include RDFObjects::Resource
  end
    
  class Graph
    include RDFObjects::Graph
  end    
end # RDF