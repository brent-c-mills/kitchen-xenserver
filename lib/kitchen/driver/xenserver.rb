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

      #VM CONFIGS (Set to match your environment)
      default_config :server_name, 'VM_HOSTNAME'
      default_config :server_template, 'VM_TEMPLATE'

      #VM SSH CONFIGS (Set to match your template)
      default_config :username, 'root'
      default_config :password, 'VM_PASSWORD'
      default_config :ip_address, 'VM_STATIC_IP'
      default_config :hostname, 'VM_STATIC_HOSTNAME / IP' #This variable is used by 'kitchen verify' for SSH.
      default_config :port, '22'
      default_config :ssh_timeout, 3
      default_config :ssh_retries, 50

      #XENSERVER CONFIGS
      default_config :storage_repo, 'XENSERVER_STORAGE_REPO'

      #CONNECTION CONFIGS (Set to match your Xenserver instance)
      def self.connection
        conn = Fog::Compute.new({
          :provider           => 'Xenserver',
          :xenserver_url      => 'XENSERVER_URL',
          :xenserver_username => 'XENSERVER_USERNAME',
          :xenserver_password => 'XENSERVER_PASSWORD',
        })
      end
      
      def create(state)
        server = Xenserver.new.get_server
        if !server.nil?
          print("Server #{config[:server_name]} already exists.")
          return
        else
          Xenserver.new.create_server
          print("Server #{config[:server_name]} has been created.")
        end
        sleep(60)
      end

      def create_server
        sr = Xenserver.connection.storage_repositories.find { |sr| sr.name ==  config[:storage_repo] }
        image_uuid = UUIDTools::UUID.random_create.to_s
        sr_mount_point = "/var/run/sr-mount/#{sr.uuid}"
        destination = File.join(sr_mount_point, "#{image_uuid}.vhd")
        sr.scan

        Xenserver.connection.servers.create   :name           => config[:server_name],
                                              :template_name  => config[:server_template]
      end

      def converge(state)
        print("Attempting SSH to #{config[:server_name]} at #{config[:ip_address]}:#{config[:port]} as user #{config[:username]}.")

        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")

        Kitchen::SSH.new(config[:ip_address], config[:username], password: config[:password]) do |conn|
          run_remote(provisioner.install_command, conn)
          run_remote(provisioner.init_command, conn)
          transfer_path(sandbox_dirs, provisioner[:root_path], conn)
          run_remote(provisioner.prepare_command, conn)
          run_remote(provisioner.run_command, conn)
        end
      end

      def destroy(state)
        server = Xenserver.new.get_server
        if server.nil?
          info("Server #{config[:server_name]} does not exist.")
          return
        else
          if server.running?
            Xenserver.new.shutdown_server
          end
          server.destroy
          info("Server #{config[:server_name]} has been destroyed.")
        end
      end

      def get_server
        Xenserver.connection.servers.find { |server| server.name == config[:server_name] }
      end

      def shutdown_server
        server = Xenserver.new.get_server
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

