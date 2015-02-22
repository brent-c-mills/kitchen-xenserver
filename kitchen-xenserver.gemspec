# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/xenserver_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-xenserver'
  spec.version       = Kitchen::Driver::XENSERVER_VERSION
  spec.authors       = ['Brent Mills']
  spec.email         = ['brent.c.mills@gmail.com']
  spec.description   = %q{A Test Kitchen Driver for Xenserver}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/kaizoku0506/kitchen-xenserver'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.0'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'fog', '~> 1.24'
  spec.add_dependency 'fog-xenserver', '~> 0.1'
  spec.add_dependency 'uuidtools', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 0'

  spec.add_development_dependency 'cane', '~> 0'
  spec.add_development_dependency 'tailor', '~> 0'
  spec.add_development_dependency 'countloc', '~> 0'
end
