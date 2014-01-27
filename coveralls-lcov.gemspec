# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coveralls/lcov/version'

Gem::Specification.new do |spec|
  spec.name          = "coveralls-lcov"
  spec.version       = Coveralls::Lcov::VERSION
  spec.authors       = ["Kenji Okimoto"]
  spec.email         = ["okimoto@clear-code.com"]
  spec.summary       = %q{Post coverage information to coveralls.io}
  spec.description   = %q{Post coverage information to coveralls.io}
  spec.homepage      = "https://github.com/okkez/coveralls-lcov"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
