# encoding: UTF-8
#
# Author: Stefano Harding <riddopic@gmail.com>
# Cookbook Name:: websphere
# Library:: transfer
#
# Copyright (C) 2014 Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module WebSphere; end

module WebSphere::Transfer
  def self.included(base)
    base.class_eval do
      include ClassMethods
    end
  end
  private_class_method :included

  module ClassMethods
    def list
      @list ||= Garcon::List.new
    end

    def sources
      @sources ||= []
    end

    def bundles
      @bundles ||= active_bundles
    end

    def active_bundles
      buns = []
      [ :iim, :was,
        :suppl, :sdk].map { |b| buns << b if node[:websphere][b][:install] }
      buns
    end

    def base_directories
      [ node[:websphere][:binairy_directory],
        node[:websphere][:was_install_root],
        node[:websphere][:ihs_install_root],
        node[:websphere][:plugin_install_root],
        node[:websphere][:iim_install_root]
      ].flatten.each { |dir| mkdir dir }
    end

    def mkdir(dir)
      directory dir do
        owner node[:websphere][:user]
        group node[:websphere][:group]
        mode 00755
        recursive true
      end
    end

    def file_vaid?(file, checksum)
      if ::File.exists?(file) && Helpers.checksum(file) == checksum
        Chef::Log.debug "found '#{file}' with matching checksum"
        true
      else
        false
      end
    end

    def unzip(file, bundle)
      zip_file = ::File.join(Chef::Config[:file_cache_path], file)
      dest_dir = ::File.join(node[:websphere][:binairy_directory], bundle.to_s)
      Helpers.unzip(zip_file, dest_dir, node[:websphere][:prune_zipfiles])
    end

    def generate_file_list
      bundles.each do |bundle|
        if node[:websphere][bundle][:install]
          node[:websphere][bundle][:files].each do |file|
            if file_vaid?(file[:name], file[:checksum])
              unzip(file[:name], bundle)
            else
              list << file[:name]
              sources << uri_join(node[:websphere][:repository_url], file[:name])
            end
          end
        end
      end
    end

    def http_get(files = sources, destination = Chef::Config[:file_cache_path])
      server = URI.parse(node[:websphere][:repository_url]).host
      site_sucker(files, destination, server)
    end

    def install_runner
      base_directories
      generate_file_list
      http_get
    end
  end
end

Chef::Recipe.send(:include, WebSphere::Transfer)
