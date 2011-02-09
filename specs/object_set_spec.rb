require 'rubygems'
require File.dirname(__FILE__) + '/../lib/rdf/rdfobjects'
require 'rdf/ntriples'
describe "An RDF-RDFObject ObjectSet" do
  before(:each) do
    @graph = RDF::Graph.load(File.dirname(__FILE__) + '/files/test.nt')
  end  
  
  it "should be what is returned from requesting a predicate from a Resource" do
    u = @graph['http://example.org/resource1']
    u['http://example.org/property'].should be_kind_of(RDF::RDFObjects::ObjectSet)
  end
  it "should be an Array object" do
    u = @graph['http://example.org/resource1']
    u['http://example.org/property'].should be_kind_of(RDF::RDFObjects::ObjectSet)    
  end
  
  it "should have subject and predicate attributes" do
    u = @graph['http://example.org/resource1']
    u['http://example.org/property'].should respond_to(:subject)
    u['http://example.org/property'].should respond_to(:predicate)
    u['http://example.org/property'].subject.should ==(RDF::URI.intern('http://example.org/resource1'))
    u['http://example.org/property'].predicate.should ==(RDF::URI.intern('http://example.org/property'))
  end
  
  it "should set the subject and predicate with #set_statement" do
    objset = []
    objset.extend(RDF::RDFObjects::ObjectSet)
    objset.set_statement(RDF::Statement.new(RDF::URI.intern('http://example.org/1'), RDF.type, RDF::FOAF.Person))
    objset.subject.should ==(RDF::URI.intern('http://example.org/1'))
    objset.predicate.should ==(RDF.type)
  end
  it "should affect the graph when appended with #<<" do
    u = @graph['http://example.org/resource1']
    prop = u['http://example.org/property']
    prop << RDF::URI.intern('http://example.org/fooBar')
    prop.should include(RDF::URI.intern('http://example.org/fooBar'))
    match = false
    @graph.query(:subject=>u,:predicate=>RDF::URI.intern('http://example.org/property'),
      :object=>RDF::URI.intern('http://example.org/fooBar')).each do |stmt|
        match = true  
      
    end
    match.should be_true
  end
  
  it "should affect the graph and self when #clear is called" do
    u = @graph['http://example.org/resource1']
    prop = u['http://example.org/property']
    prop.clear
    prop.should be_empty
    u['http://example.org/property'].should be_empty
  end
end
