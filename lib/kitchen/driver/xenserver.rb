# -*- encoding: utf-8 -*-
#
# Author:: Brent Mills (<brent.c.mills@gmail.com>)
#
# Copyright (C) 2015, Brent Mills
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# This Driver makes heavy use of fog-Xenserver.  For fog-Xenserver 
# documentation, see github.com/fog/fog-Xenserver.

require 'kitchen'
require 'json'
require 'fog'
require 'uuidtools'
gem 'fog-xenserver'

module Kitchen
  module Driver
    class Xenserver < Kitchen::Driver::SSHBase

      #KITCHEN-XENSERVER CONFIGS
      default_config :overwrite_vms, ENV['OVERWRITE_VMS']
      default_config :created_vm, 'false'

      #VM CONFIGS (Set to match your environment)
      default_config :server_name, 'vmname'
      default_config :server_template, 'vmtemplate'

      #VM SSH CONFIGS (Set to match your template)
      default_config :username, 'root'
      default_config :password, 'vmpassword'
      default_config :hostname, '0.0.0.0'
      default_config :port, '22'
      default_config :ssh_timeout, 3
      default_config :ssh_retries, 50

      #XENSERVER CONFIGS
      default_config :storage_repo, 'storagerepo'
      default_config :xenserver_url, '0.0.0.0'
      default_config :xenserver_username, 'root'
      default_config :xenserver_password, 'password'

      #CONNECTION CONFIGS (Set to match your Xenserver instance)
      def connection
        conn = Fog::Compute.new({
          :provider           => 'Xenserver',
          :xenserver_url      => config[:xenserver_url],
          :xenserver_username => config[:xenserver_username],
          :xenserver_password => config[:xenserver_password],
        })
      end
      
      def create(state)
        server = get_server
        if !server.nil?
          print("Server #{config[:server_name]} already exists.")
          if config[:hostname] == '0.0.0.0'
            if server.running?
              get_address
            else
              print("Server #{config[:server_name]} is not running.")
              print("Starting server #{config[:server_name]}...")
              server.start
            end
          end
          return
        else
          create_server
        end
      end

      def create_server
        sr = connection.storage_repositories.find { |sr| sr.name ==  config[:storage_repo] }
        image_uuid = UUIDTools::UUID.random_create.to_s
        sr_mount_point = "/var/run/sr-mount/#{sr.uuid}"
        destination = File.join(sr_mount_point, "#{image_uuid}.vhd")
        sr.scan

        connection.servers.create   :name           => config[:server_name],
                                    :template_name  => config[:server_template]

        config[:created_vm] = 'true'

        print("Server #{config[:server_name]} has been created.")
        sleep(40)
        if config[:hostname] == '0.0.0.0'
          get_address
        end
      end

      def converge(state)
        server = get_server

        if !server.nil?
          if config[:created_vm] == 'true'
            if !server.running?
              server.start
            end
          else
            if config[:overwrite_vms] == 'true'
              print("A VM by the name of #{config[:server_name]} already exists.")
              print("Destroying #{config[:server_name]} and overwriting...")
              server.destroy
              create_server
              get_address
            else
              print("ERROR:  A VM by the name of #{config[:server_name]} already exists.")
              print("overwrite_vms is set to #{config[:overwrite_vms]}.")
              return
            end
          end
        end

        if config[:hostname] == '0.0.0.0'
          sleep(40)
          get_address
        end

        print("Attempting SSH to #{config[:server_name]} at #{config[:hostname]}:#{config[:port]} as user #{config[:username]}.")

        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")

        Kitchen::SSH.new(config[:hostname], config[:username], password: config[:password]) do |conn|
          run_remote(provisioner.install_command, conn)
          run_remote(provisioner.init_command, conn)
          transfer_path(sandbox_dirs, provisioner[:root_path], conn)
          run_remote(provisioner.prepare_command, conn)
          run_remote(provisioner.run_command, conn)
        end
      end

      def destroy(state)
        server = get_server
        if server.nil?
          info("Server #{config[:server_name]} does not exist.")
          return
        else
          if server.running?
            shutdown_server
          end
          server.destroy
          info("Server #{config[:server_name]} has been destroyed.")
        end
      end

      def get_server
        connection.servers.get_by_name(config[:server_name])
      end

      def get_address
        server = get_server
        if !server.nil?
          mac_address = server.vifs.first.mac
          ip_address = `cat /var/lib/jenkins/dhcp_spyglass/leases.record | grep -m1 -B6 -A1 #{mac_address} | grep lease | awk '{ print $2 }' | xargs echo -n`
          config[:hostname] = "#{ip_address}"
          print("Existing and ip_address set to:  #{ip_address}")
          print("Existing and Hostname set to:  #{config[:hostname]}")
        end
      end

      def shutdown_server
        server = get_server
        if server.nil?
          info("Server #{config[:server_name]} does not exist.")
          return
        else
          server.clean_shutdown
          info("Server #{config[:server_name]} has been shut down cleanly.")
        end
      end
    end
  end
end
