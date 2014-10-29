# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'build_light/version'

Gem::Specification.new do |gem|

  gem.authors       = ["Tom Meier", "Ash McKenzie", "Warner Godfrey", "Daniel Angel Bradford"]
  gem.email         = ["email"]
  gem.description   = %q{description}
  gem.summary       = %q{summary}
  gem.homepage      = "http://hooroo.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "build_light"
  gem.require_paths = ["lib"]
  gem.version       = BuildLight::VERSION

  gem.add_dependency "json", "~> 1.6.5"
  gem.add_dependency "logging"

  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "awesome_print"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"

end