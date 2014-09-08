begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant Netinfo plugin must be run within vagrant.'
end

if Vagrant::VERSION < '1.6.0'
  puts 'WARNING: The Vagrant Netinfo plugin has only been tested with vagrant 1.6.x'
  puts 'If it works with your version of vagrant, send me a pull request updating this version check ;)'
end

module VagrantPlugins
  module Netinfo
    class Plugin < Vagrant.plugin('2')
      name 'Netinfo'
      description 'Display network forwardding information on a running VM'

      command 'netinfo' do
        require_relative 'command'
        Command
      end

    end
  end
end
