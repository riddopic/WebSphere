# encoding: UTF-8
#
# Author: Stefano Harding <riddopic@gmail.com>
# Cookbook Name:: websphere
# Recipe:: _transfer
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

single_include 'websphere::default'
safe_require('hoodie', constant: 'Hoodie')
safe_require('zip', gem_name: 'rubyzip', constant: 'Zip')

install_runner

# sources = []
# list = List.new
#
# [ node[:websphere][:binairy_directory],
#   node[:websphere][:was_install_root],
#   node[:websphere][:ihs_install_root],
#   node[:websphere][:plugin_install_root],
#   node[:websphere][:iim_install_root]
# ].flatten.each do |dir|
#   directory dir do
#     owner node[:websphere][:user]
#     group node[:websphere][:group]
#     mode 00755
#     recursive true
#   end
# end
#
# [:iim, :was, :suppl, :sdk].each do |bundle|
#   directory ::File.join(node[:websphere][:binairy_directory], bundle.to_s) do
#     owner node[:websphere][:user]
#     group node[:websphere][:group]
#     mode 00755
#     recursive true
#   end
#
#   if node[:websphere][bundle][:install]
#     # Package up the file to be consumed by site_sucker (I suck at names)
#     node[:websphere][bundle][:files].each do |file|
#       zip_file  = ::File.join(Chef::Config[:file_cache_path], file[:name])
#       unzip_dir = ::File.join(node[:websphere][:binairy_directory], bundle.to_s)
#
#       if ::File.exists?(zip_file) && (checksum(zip_file) == file[:checksum])
#         Chef::Log.debug "found '#{zip_file}' with matching checksum"
#         unzip(zip_file, unzip_dir, node[:websphere][:prune_zipfiles])
#         list.delete(file[:name])
#         notify_observers(bundle)
#
#       else
#         list << file[:name]
#         sources << uri_join(node[:websphere][:repository_url], file[:name])
#
#         observable_event(zip_file) do
#           name = ::File.basename(zip_file)
#           unzip(zip_file, unzip_dir, node[:websphere][:prune_zipfiles])
#           list.delete(name)
#           notify_observers(bundle)
#         end
#       end
#     end
#   end
# end
#
# unless sources.empty?
#   server = URI.parse(node[:websphere][:repository_url]).host
#   destination = Chef::Config[:file_cache_path]
#   recipe_block(:suckersite) { site_sucker(sources, destination, server) }
# end
