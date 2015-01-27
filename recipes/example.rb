# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: example
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

#       T H I S   I S   A   E X A M P L E   R E C I P E   F O R
#       D E M O N S T R A T I O N   P U R P O S E S   O N L Y !

single_include 'websphere::install'

# bag = Chef::DataBagItem.load(:websphere, node[:wpf][:data_bag]
#   ).to_hash.recursively_normalize_keys
#
# bag[:profiles].each do |profile|
#   hash_to(:websphere_profile, profile).run_action(:create)
# end

websphere_profile 'Dmgr01' do
  enable_admin_security true
  server_type         'DEPLOYMENT_MANAGER'
  profile_path        '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01'
  template_path       '/opt/IBM/WebSphere/AppServer/profileTemplates/management'
  node_name           'Cell01Manager'
  cell_name           'Cell01Manager'
  host_name            node[:fqdn]
  admin_username      'wasadm'
  admin_password      'wasadm'
  action [:create, :start]
end

websphere_profile 'Cell01Node01' do
  enable_admin_security true
  profile_path        '/opt/IBM/WebSphere/AppServer/profiles/Cell01Node01'
  template_path       '/opt/IBM/WebSphere/AppServer/profileTemplates/managed'
  node_name           'Cell01Node01'
  host_name            node[:fqdn]
  dmgr_host            node[:fqdn]
  dmgr_admin_username 'wasadm'
  dmgr_admin_password 'wasadm'
  admin_username      'wasadm'
  admin_password      'wasadm'
  action [:create, :start]
end
