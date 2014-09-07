# coding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)
require 'vagrant-netinfo/version'

Gem::Specification.new do |spec|
  spec.name           = 'vagrant-netinfo'
  spec.version        = VagrantPlugins::Netinfo::VERSION
  spec.authors        = ['Jan Vansteenkiste']
  spec.email          = ['jan@vstone.eu']
  spec.summary        = %q{Display network information on a running vagrant box}
  spec.description    = %q{Shows forwarded ports of a running vagrant box}
  spec.homepage       = 'https://github.com/vStone/vagrant-netinfo'
  spec.license        = 'MIT'

  spec.files          = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "awesome_print"

end
