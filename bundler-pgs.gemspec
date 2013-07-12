# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler-pgs/version'

Gem::Specification.new do |gem|
  gem.name          = "bundler-pgs"
  gem.version       = Bundler::Pgs::VERSION
  gem.authors       = ["Thomas Baustert"]
  gem.email         = ["business@thomasbaustert.de"]
  gem.description   = %q{bundler patch to support private gem server (pgs)}
  gem.summary       = %q{bundler patch to support private gem server (pgs)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'bundler'
end
