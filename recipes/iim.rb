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

include_recipe 'garcon::default'

g = Chef::Resource::Group.new(node[:wpf][:user][:group], run_context)
node[:wpf][:user][:system] ? (g.system true) : (g.gid node[:wpf][:user][:gid])
g.not_if { node[:wpf][:user][:username] == 'root' }
g.run_action(:create)

u = Chef::Resource::User.new(node[:wpf][:user][:name], run_context)
u.comment  node[:wpf][:user][:comment]
u.home     node[:wpf][:user][:home]
u.gid      node[:wpf][:user][:group]
u.supports manage_home: true
node[:wpf][:user][:system] ? (u.system true) : (u.uid node[:wpf][:user][:uid])
u.not_if { node[:wpf][:user][:username] == 'root' }
u.run_action(:create)

concurrent 'WebSphere Installation Manager' do
  block do
    monitor.synchronize do
      %w(gtk2-engines gtk2 libgcc glibc).each do |pkg|
        package pkg
      end

      %w(gtk2-engines.i686 gtk2.i686 libgcc.i686 glibc.i686 libXtst.i686
         libcanberra-gtk2.i686 PackageKit-gtk-module.i686).each do |pkg|
        package pkg
      end
    end
  end
end

file '/etc/profile.d/websphere.sh' do
  owner 'root'
  group 'root'
  mode 00755
  content <<-EOD
    # Increase the file descriptor limit to support WAS
    ulimit -n 20480
  EOD
  action :create
end

file '/etc/security/limits.d/websphere.conf' do
  owner 'root'
  group 'root'
  mode 00755
  content <<-EOD
    # Increase the limits for the number of open files for the pam_limits
    # module to support WAS
    * soft nofile 20480
    * hard nofile 20480
  EOD
  action :create
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

websphere_package :iim do
  install_fixes :all
  install_from  :files
  install_files [node[:iim][:files][:with_pkgutil]]
  action :install
end

repository_auth node[:wpf][:authorize][:url] do
  username        node[:wpf][:authorize][:username]
  password        node[:wpf][:authorize][:password]
  master_passwd   node[:wpf][:authorize][:master_passwd]
  secure_storage  node[:wpf][:authorize][:secure_storage]
  not_if        { node[:wpf][:authorize][:username].nil? }
  action :store
end
