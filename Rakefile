#!/usr/bin/env ruby
#$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'rake'

require "spec/rake/spectask"



desc "Run all specs"

Spec::Rake::SpecTask.new("specs") do |t|

  t.spec_files = FileList["specs/*.rb"]

end


desc "Build the rdf-rdfobjects-#{File.read('VERSION').chomp}.gem file"
task :build do
  sh "gem build .gemspec"
end