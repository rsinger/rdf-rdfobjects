#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version = File.read('VERSION').chomp
  gem.date = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name = 'rdf-rdfobjects'
  gem.homepage = 'http://github.com/rsinger/rdf-rdfobjects'
  gem.license = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary = 'An object oriented interface for working with Resource Description Framework (RDF) data in RDF.rb.'
  gem.description = 'An object oriented interface for working with Resource Description Framework (RDF) data in RDF.rb.'

  gem.authors = ['Ross Singer']
  gem.email = 'rdfobjects@googlegroups.com'

  gem.platform = Gem::Platform::RUBY
  gem.files = %w(README VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths = %w(lib)
  gem.extensions = %w()
  gem.test_files = %w()
  gem.has_rdoc = false

  gem.required_ruby_version = '>= 1.8.1'
  gem.requirements = []
  gem.add_runtime_dependency 'addressable', '>= 2.2'
  gem.add_runtime_dependency 'rdf', '>= 0.3.1'
  gem.add_development_dependency 'yard', '>= 0.6.0'
  gem.add_development_dependency 'rspec', '>= 2.1.0'
  gem.post_install_message = nil
end