require 'rubygems'
require File.dirname(__FILE__) + '/../lib/rdf/rdfobjects'
require 'rdf/ntriples'
include RDF
describe "An RDF::RDFObjects::Resource" do
  before(:each) do
    @graph = RDF::Graph.load(File.dirname(__FILE__) + '/files/test.nt')
  end  
  it "should be extended on all RDF::URIs" do
    uri = @graph.create('http://example.org/resource1')
    uri.should be_kind_of(RDF::RDFObjects::Resource)
    uri2 = RDF::URI.new("http://example.org/other-resource")
    uri2.should be_kind_of(RDF::RDFObjects::Resource)
  end
  
  it "should be extended on all RDF::Nodes" do
    anon = @graph.create('_:anon')
    anon.should be_kind_of(RDF::RDFObjects::Resource)
    n2 = RDF::Node.new()
    n2.should be_kind_of(RDF::RDFObjects::Resource)
  end
  
  it "should contain the graph it was created from" do
    uri = @graph['http://example.org/resource1']
    uri.graph.should equal(@graph)
  end
  
  it "should add a URI string as a URI object to the graph using #relate" do
    uri = @graph['http://example.org/resource1']
    uri.relate("http://example.org/vocabulary/test", "http://example.org/foo/bar")
    matched = false
    @graph.query([uri, RDF::URI.intern("http://example.org/vocabulary/test"), RDF::URI.intern("http://example.org/foo/bar")]).each do |stmt|
      matched = true if stmt.subject == uri && stmt.predicate == RDF::URI.intern("http://example.org/vocabulary/test") && stmt.object == RDF::URI.intern("http://example.org/foo/bar")
    end
    matched.should be_true
  end
  
  it "should add a typed literal to the graph from Ruby object using #assert" do 
    uri = @graph['http://example.org/resource1']
    now = DateTime.now
    uri.assert("http://example.org/vocabulary/test", now)
    matched = false
    object = nil
    @graph.query([uri, RDF::URI.intern("http://example.org/vocabulary/test"), RDF::Literal.new(now)]).each do |stmt|
      matched = true if stmt.subject == uri && stmt.predicate == RDF::URI.intern("http://example.org/vocabulary/test") && stmt.object == RDF::Literal.new(now)
      object = stmt.object
    end
    matched.should be_true    
    object.plain?.should be_false
  end
  
  it "should add a Literal to the graph using #assert" do 
    uri = @graph['http://example.org/resource1']
    o = RDF::Literal.new("Foo Bar", :language=>:en)
    uri.assert("http://example.org/vocabulary/test", o)
    matched = false
    object = nil
    @graph.query([uri, RDF::URI.intern("http://example.org/vocabulary/test"), o]).each do |stmt|
      matched = true if stmt.subject == uri && stmt.predicate == RDF::URI.intern("http://example.org/vocabulary/test") && stmt.object == o
      object = stmt.object
    end
    matched.should be_true    
    object.plain?.should be_false
  end  
    
  it "should add a URI object to the graph using #assert" do
    uri = @graph['http://example.org/resource1']
    uri.assert("http://example.org/vocabulary/test", RDF::URI.intern("http://example.org/foo/bar"))
    matched = false
    @graph.query([uri, RDF::URI.intern("http://example.org/vocabulary/test"), RDF::URI.intern("http://example.org/foo/bar")]).each do |stmt|
      matched = true if stmt.subject == uri && stmt.predicate == RDF::URI.intern("http://example.org/vocabulary/test") && stmt.object == RDF::URI.intern("http://example.org/foo/bar")
    end
    matched.should be_true
  end  
  
  it "should add a URI string as a Literal object to the graph using #assert" do
    uri = @graph['http://example.org/resource1']
    uri.assert("http://example.org/vocabulary/test", "http://example.org/foo/bar")
    matched = false
    @graph.query([uri, RDF::URI.intern("http://example.org/vocabulary/test"), RDF::Literal.new("http://example.org/foo/bar")]).each do |stmt|
      matched = true if stmt.subject == uri && stmt.predicate == RDF::URI.intern("http://example.org/vocabulary/test") && stmt.object == RDF::Literal.new("http://example.org/foo/bar")
    end
    matched.should be_true
  end  
  
  it "should return an AssertionSet if an RDF::Vocabulary is passed to #[]" do
    uri = @graph['http://example.org/resource1']
    @graph << [uri, RDF.type, RDF::FOAF.Person]
    @graph << [uri, RDF::FOAF.name, "John Doe"]
    uri[RDF::FOAF].should be_kind_of(Hash)
    uri[RDF::FOAF].should be_kind_of(RDF::RDFObjects::AssertionSet)
    uri[RDF::FOAF].keys.should include(RDF::FOAF.name.to_s)
    uri[RDF.to_rdf].should be_kind_of(Hash)
    uri[RDF.to_rdf].should be_kind_of(RDF::RDFObjects::AssertionSet)
    uri[RDF.to_rdf].keys.should include(RDF.type.to_s)    
  end
  
  it "should return an ObjectSet if an RDF::Vocabulary property is passed to #[]" do
    uri = @graph['http://example.org/resource1']
    @graph << [uri, RDF.type, RDF::FOAF.Person]
    @graph << [uri, RDF::FOAF.name, "Jonathan Doe"]
    @graph << [uri, RDF::FOAF.name, "Jon Doe"]    
    uri[RDF::FOAF.name].should be_kind_of(Array)
    uri[RDF::FOAF.name].should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri[RDF::FOAF.name].length.should ==(2)
    uri[RDF.type].should be_kind_of(Array)
    uri[RDF.type].should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri[RDF.type].length.should ==(1)
  end  
  
  it "should return an ObjectSet if a URI String is passed to #[]" do
    uri = @graph['http://example.org/resource1']
    @graph << [uri, RDF.type, RDF::FOAF.Person]
    @graph << [uri, RDF::FOAF.name, "Jonathan Doe"]
    @graph << [uri, RDF::FOAF.name, "Jon Doe"]    
    uri["http://xmlns.com/foaf/0.1/name"].should be_kind_of(Array)
    uri["http://xmlns.com/foaf/0.1/name"].should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri["http://xmlns.com/foaf/0.1/name"].length.should ==(2)
    uri["http://www.w3.org/1999/02/22-rdf-syntax-ns#type"].should be_kind_of(Array)
    uri["http://www.w3.org/1999/02/22-rdf-syntax-ns#type"].should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri["http://www.w3.org/1999/02/22-rdf-syntax-ns#type"].length.should ==(1)
  end  
  
  it "should return an empty ObjectSet if an RDF::Vocabulary property is passed to #[] that doesn't exist in graph" do
    uri = @graph['http://example.org/resource1']
    @graph << [uri, RDF.type, RDF::FOAF.Person]
    @graph << [uri, RDF::FOAF.name, "John Doe"]  
    uri[RDF::FOAF.nick].should be_kind_of(Array)
    uri[RDF::FOAF.nick].should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri[RDF::FOAF.nick].length.should ==(0)
  end  
  
  it "should replace all assertions with the subject and predicate when objects are added with #[]=" do
    uri = @graph['http://example.org/resource1']
    @graph << [uri, RDF.type, RDF::FOAF.Person]
    @graph << [uri, RDF::FOAF.name, "Robert Zimmerman"]  
    uri[RDF::FOAF.name].should be_kind_of(Array)
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Robert Zimmerman"))
    uri[RDF::FOAF.name]= "Bob Dylan"
    uri[RDF::FOAF.name].should be_kind_of(Array)
    uri[RDF::FOAF.name].length.should ==(1)
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Bob Dylan"))
    uri[RDF::FOAF.name].should_not include(RDF::Literal.new("Robert Zimmerman"))
  end
  
  it "should allow arrays of objects to be passed to #[]=" do
    uri = @graph['http://example.org/resource1']
    uri[RDF::FOAF.name]= ["Robert Zimmerman", "Bob Dylan", "Lucky Wilbury"]
    uri[RDF::FOAF.name].length.should ==(3)
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Lucky Wilbury"))
    uri[RDF::FOAF.pastProject]= [RDF::URI.intern("http://dbpedia.org/resource/The_Band"), RDF::URI.intern("http://dbpedia.org/resource/Traveling_Wilburys")]
    uri[RDF::FOAF.pastProject].length.should ==(2)
    uri[RDF::FOAF.pastProject].should include(RDF::URI.intern("http://dbpedia.org/resource/Traveling_Wilburys"))
  end
  
  it "should allow a statement to be removed from the graph with #remove()" do
    uri = @graph['http://example.org/resource1']
    uri[RDF::FOAF.name]= ["Robert Zimmerman", "Bob Dylan", "Lucky Wilbury"]    
    uri[RDF::FOAF.name].length.should ==(3)
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Lucky Wilbury"))
    uri.remove(RDF::FOAF.name, "Lucky Wilbury")    
    uri[RDF::FOAF.name].length.should ==(2)
    uri[RDF::FOAF.name].should_not include(RDF::Literal.new("Lucky Wilbury"))    
    uri[RDF.type]= RDF::FOAF.Person
    uri[RDF.type].length.should ==(1)
    uri.remove("http://www.w3.org/1999/02/22-rdf-syntax-ns#type", RDF::FOAF.Person)
    uri[RDF.type].should be_empty
  end
  
  it "should allow a statement to be added to the graph with #push()" do
    uri = @graph['http://example.org/resource1']
    uri[RDF::FOAF.name]= "Robert Zimmerman"
    uri[RDF::FOAF.name].length.should ==(1)
    uri.push(RDF::FOAF.name, "Bob Dylan")    
    uri[RDF::FOAF.name].length.should ==(2)    
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Bob Dylan"))    
  end
  
  it "should return an Array of predicates associated with the subject in the graph" do
    uri = @graph['http://example.org/resource1']
    uri.predicates.should be_kind_of(Array)
    uri.predicates.length.should ==(1)
    uri.predicates.should include(RDF::URI.intern("http://example.org/property"))
    uri.push(RDF.type, RDF::OWL.Thing)
    uri.predicates.length.should ==(2)    
    uri.predicates.should include(RDF.type)
  end
  
  it "should return an Array of RDF::Statements from the graph with the resource as the subject" do
    uri = @graph['http://example.org/resource1']
    uri.statements.should be_kind_of(Array)    
    uri.statements.first.should be_kind_of(RDF::Statement)
    uri.statements.first.subject.should ==(uri)
    uri.statements.first.object.should ==(RDF::URI.intern("http://example.org/resource2"))
  end
  
  it "should return an Array of RDF::Resources that this resource is an object of in the graph" do
    uri = @graph['http://example.org/resource2']
    uri.object_of.should be_kind_of(Array)
    uri.object_of.should_not be_empty
    uri.object_of.should include(RDF::URI.intern('http://example.org/resource1'))
  end
  
  it "should return a Hash of properties associated with the resource in the graph" do
    uri = @graph['http://example.org/resource1']
    uri.properties.should be_kind_of(Hash)
    uri.properties.should_not be_empty
    uri.properties.values.first.should be_kind_of(RDF::RDFObjects::ObjectSet)
  end
  
  it "should alias assertions for properties" do
    uri = @graph['http://example.org/resource1']
    uri.assertions.should be_kind_of(Hash)
    uri.assertions.should_not be_empty
    uri.assertions.should ==(uri.properties)    
  end
  
  it "should set the RDF.type for a resource with #type=" do
    uri = @graph['http://example.org/resource1']
    uri[RDF.type].should be_empty
    uri.type = RDF::FOAF.Person
    uri[RDF.type].should_not be_empty    
    uri[RDF.type].should include(RDF::FOAF.Person)
  end
  
  it "should enable the convenience method #type" do
    uri = @graph['http://example.org/resource1']
    uri.type = RDF::FOAF.Person
    uri.type.should be_kind_of(RDF::RDFObjects::ObjectSet)    
    uri.type.should include(RDF::FOAF.Person)
  end
  
  it "should be able to clear all statements about the resource from the graph" do
    uri = @graph['http://example.org/resource1']
    uri.properties.should_not be_empty
    uri.clear
    uri.properties.should be_nil
    @graph['http://example.org/resource1'].should be_nil
    @graph.should_not be_empty
  end
  
  it "should allow dot syntax to access properties" do
    uri = @graph['http://example.org/resource1']
    uri.push(RDF::FOAF.name, "Bob Dylan")    
    uri.FOAF.name.length.should ==(1)    
    uri.FOAF.name.should be_kind_of(RDF::RDFObjects::ObjectSet)
    uri.FOAF.name.should include(RDF::Literal.new("Bob Dylan"))
    uri.FOAF.name << "Robert Zimmerman"
    uri[RDF::FOAF.name].length.should ==(2)     
    uri.FOAF.name.should include(RDF::Literal.new("Robert Zimmerman"))    
    uri[RDF::FOAF.name].should include(RDF::Literal.new("Bob Dylan"))    
  end
  
  it "should allow dot syntax to access vocabularies" do
    uri = @graph['http://example.org/resource1']
    uri.push(RDF::FOAF.name, "Bob Dylan")    
    uri.FOAF.made << RDF::URI.new("http://dbpedia.org/resource/Blonde_on_Blonde")
    uri.FOAF.should be_kind_of(Hash)
    uri.FOAF.should be_kind_of(RDF::RDFObjects::AssertionSet)    
    uri.FOAF.keys.should include(RDF::FOAF.made.to_s)
  end  
end