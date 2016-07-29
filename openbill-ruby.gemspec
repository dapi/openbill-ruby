# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openbill/version'

Gem::Specification.new do |spec|
  spec.name          = "openbill-ruby"
  spec.version       = Openbill::VERSION
  spec.authors       = ["Danil Pismenny"]
  spec.email         = ["danil@brandymint.ru"]

  spec.summary       = %q{Ruby gem for openbill billing system}
  spec.description   = %q{This gem helps to use openbill-core}
  spec.homepage      = "http://brandymint.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "money"
  spec.add_dependency "sequel"
  spec.add_dependency "virtus"
  spec.add_dependency "pg"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
