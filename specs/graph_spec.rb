require 'rubygems'
require File.dirname(__FILE__) + '/../lib/rdf/rdfobjects'
require 'rdf/ntriples'
include RDF
describe "An RDF-RDFObject Graph" do
  before(:each) do
    @graph = RDF::Graph.load(File.dirname(__FILE__) + '/files/test.nt')
  end
  
  after(:each) do
    @graph.clear
  end
  
  it "should automatically extend RDF::Graph to use RDF::RDFObjects::Graph" do
    @graph.should be_kind_of(RDF::RDFObjects::Graph)
  end
  
  it "should respond to RDF::RDFObjects::Graph methods" do
    @graph.should respond_to(:"[]")
    @graph.should respond_to(:create)
    @graph.should respond_to(:to_ntriples)
  end    
  
  it "should return an RDF::RDFObjects::Resource on .create()" do
    graph = RDF::Graph.new
    uri = graph.create('http://example.org/1')
    uri.should be_kind_of(RDF::RDFObjects::Resource)
  end
  
  it "should set the graph attribute on the RDF::RDFObjects::Resource on .create()" do
    graph = RDF::Graph.new
    uri = graph.create('http://example.org/1')
    uri.graph.should equal(graph)
  end  
  
  it "should return nil on [] if URI not in graph" do
    graph = RDF::Graph.new
    uri = graph['http://example.org/1']
    uri.should be_nil
  end    

  it "should return an RDF::Resource on [] if URI is subject or object in graph" do
    uri = @graph['http://example.org/resource1']
    uri.should_not be_nil
    uri.FOAF.knows << RDF::URI.new('http://example.org/new-resource')
    knows = @graph['http://example.org/new-resource']
    knows.should_not be_nil
    knows.properties.should be_nil
  end  
  
  it "should add all properties from an RDF::RDFObjects::Resource to the graph when added using <<" do
    graph = RDF::Graph.new
    u = graph.create('http://example.org/new-resource')
    u.type = FOAF.Person
    u.FOAF.name = "John Doe"
    i = 0
    @graph.statements.each {|stmt| i+= 1}
    i.should equal(30)
    @graph << u
    i = 0
    @graph.statements.each {|stmt| i+= 1}
    i.should equal(32)
  end
  
  it "should produce a string when .to_ntriples is called" do
    @graph.to_ntriples.should be_kind_of(String)
  end
end