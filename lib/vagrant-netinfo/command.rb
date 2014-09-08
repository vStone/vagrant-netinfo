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

        widths = {
          :nic_id => 'nic'.length + 1,
          :protocol => 10,
          :guest_ip => 10,
          :guest_port => 5,
          :host_ip => 10,
          :host_port => 5,
          :name => 10,
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
                widths[:nic_id] = "nic: #{current_nic.to_s}".length if "nic: #{current_nic.to_s}".length > widths[:nic_id]

                widths[:host_ip] = $3.to_s.length if $3.to_s.length > widths[:host_ip]
                widths[:host_port] = $4.to_s.length if $4.to_s.length > widths[:host_port]

                widths[:guest_ip] = $5.to_s.length if $5.to_s.length > widths[:guest_ip]
                widths[:guest_port] = $6.to_s.length if $6.to_s.length > widths[:guest_port]

                widths[:name] = $1.to_s.length if $1.to_s.length > widths[:name]

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
            :name          => machine.name.to_s,
            :provider      => machine.provider_name.to_s,
            :port_forwards => machine_results
          }
        end

        header = [ ' '.ljust(widths[:nic_id]), 'guest ip'.rjust(widths[:guest_ip]), ':', 'port'.ljust(widths[:guest_port]),
          '    ',
          'host ip'.rjust(widths[:host_ip]),':', 'port'.ljust(widths[:host_port]),
          'protocol'.rjust(widths[:protocol]),
          'name'.rjust(widths[:name])
        ]

        results.each do |machine|
          @env.ui.info("Machine '#{machine[:name].to_s}' (#{machine[:provider]})")
          @env.ui.info(header.join(""))
          @env.ui.info('-' * header.join("").length)
          machine[:port_forwards].each do |fwd|
            line = []
            line << [ "nic[#{fwd[:nic_id]}]".ljust(widths[:nic_id]) ]
            line << [ fwd[:guest_ip].rjust(widths[:guest_ip]), ':', fwd[:guest_port].ljust(widths[:guest_port]) ]
            line << [ ' -> ' ]
            line << [ fwd[:host_ip].rjust(widths[:host_ip]), ':', fwd[:host_port].ljust(widths[:host_port]) ]
            line << [ fwd[:protocol].rjust(widths[:protocol]) ]
            line << [ fwd[:name].rjust(widths[:name]) ]
            opts = {}
            if fwd[:name] == 'ssh'
              opts[:color] = :yellow
            elsif fwd[:name] != "#{fwd[:protocol]}#{fwd[:host_port]}"
              opts[:color] = :red
            end

            @env.ui.info(line.join(""), opts)
          end
          @env.ui.info("")
        end
        0
      end
    end
  end
end
