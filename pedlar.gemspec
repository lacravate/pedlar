# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'pedlar/version'

Gem::Specification.new do |s|
  s.name          = "pedlar"
  s.version       = Pedlar::VERSION
  s.authors       = ["lacravate"]
  s.email         = ["lacravate@lacravate.fr"]
  s.homepage      = "https://github.com/lacravate/pedlar"
  s.summary       = "pedlar peddles interfaces (through accessors and delegation)"
  s.description   = "pedlar peddles interfaces (through accessors and delegation)"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_development_dependency 'rspec'
end
