# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: install
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
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

single_include 'garcon::default'

g = Chef::Resource::Group.new(node[:wpf][:user][:group], run_context)
node[:wpf][:user][:system] ? (g.system true) : (g.gid node[:wpf][:user][:gid])
g.run_action(:create) unless (node[:wpf][:user][:username] == 'root')

u = Chef::Resource::User.new(node[:wpf][:user][:name], run_context)
u.comment  node[:wpf][:user][:comment]
u.home     node[:wpf][:user][:home]
u.gid      node[:wpf][:user][:group]
u.supports manage_home: true
node[:wpf][:user][:system] ? (u.system true) : (u.uid node[:wpf][:user][:uid])
u.run_action(:create) unless (node[:wpf][:user][:username] == 'root')

concurrent 'WebSphere::Install' do
  block do
    monitor.synchronize do
      %w(gtk2-engines gtk2 libgcc glibc).each do |pkg|
        package pkg
      end

      %w(gtk2 libgcc glibc).each do |pkg|
        yum_package pkg do
          arch i686
        end
      end
    end
  end
end

[node[:wpf][:base],
 node[:wpf][:data_dir],
 node[:wpf][:shared_dir]].each do |dir|
  directory dir do
    owner     node[:wpf][:user][:name]
    group     node[:wpf][:user][:group]
    mode      00755
    recursive true
    action :create
  end
end

# Running Installation Manager version 1.8.1
# (internal version 1.8.1000.20141125_2157)
#
websphere_package :iim do
  install_fixes :all
  install_from  :files
  install_files [node[:iim][:files][:with_pkgutil]]
  action :install
end

auth = node[:wpf][:authorize]
repository_auth auth[:username] do
  authorizing_url auth[:url]
  password        auth[:password]
  master_passwd   auth[:master_passwd]
  secure_storage  auth[:secure_storage]
  not_if { node[:wpf][:authorize][:username].nil? }
end

# Updates to 1.8.1000.20141126_2002
#
websphere_package :iim do
  service_repository false
  action :update
end

