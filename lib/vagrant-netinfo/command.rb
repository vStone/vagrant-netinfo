require 'optparse'
require 'awesome_print'

module VagrantPlugins
  module Netinfo
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'output network mapping of the vagrant machine'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant netinfo [name]"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        columns = {
          :nic_id => 'nic id',
          :protocol => 'protocol',
          :guest  => 'guest',
          :host   => 'host',
        }
        widths = {
          :nic_id => columns[:nic_id].length + 1,
          :protocol => columns[:protocol].length + 1,
          :guest  => columns[:guest].length + 1,
          :host   => columns[:host].length + 1
        }

        results = []
        uuid = nil

        with_target_vms(argv) do |machine|
          current_nic = nil
          uuid = machine.id
          machine_results = []

          # Only active VMS pls.
          if !machine.communicate.ready?
            raise Vagrant::Errors::VMNotCreatedError
          end

          ## Looks like this is pretty provider specific.
          case machine.provider_name
          when :virtualbox
            info = machine.provider.driver.execute('showvminfo', uuid, '--machinereadable', retryable: true)
            info.split("\n").each do |line|
              current_nic = $1.to_i if line =~ /^nic(\d+)=".+?"$/
              if line =~ /^Forwarding.+?="(.+?),(.+?),(.*?),(.+?),(.*?),(.+?)"$/
                widths[:nic_id] = current_nic.to_s.length if current_nic.to_s.length > widths[:nic_id]
                widths[:host] = "#{$3.to_s}:#{$4.to_s}".length if "#{$3.to_s}:#{$4.to_s}".length > widths[:host]
                widths[:guest] =  "#{$5.to_s}:#{$6.to_s}".length if "#{$5.to_s}:#{$6.to_s}".length > widths[:guest]
                machine_results << {
                  :nic_id     => current_nic,
                  :name       => $1.to_s,
                  :protocol   => $2.to_s,
                  :host_ip    => $3.to_s,
                  :host_port  => $4.to_s,
                  :guest_ip   => $5.to_s,
                  :guest_port => $6.to_s,
                }
              end
            end
          else
            raise Vagrant::Errors::ProviderNotUsable
          end

          results << {
            :machine       => machine.name.to_s,
            :provider      => machine.provider_name.to_s,
            :port_forwards => machine_results
          }
        end

        results.each do |machine|
          machine[:port_forwards].each do |fwd|
          end
        end
        ap results, indent: -2
        0
      end
    end
  end
end
