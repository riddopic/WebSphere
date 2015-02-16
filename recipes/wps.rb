# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: wps
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

single_include 'websphere::iim'

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

# Temp
node.set[:was][:version]  = '8.0.9.20140530_2152'
node.set[:was][:features] = 'core.feature,ejbdeploy,thinclient,' \
                            'embeddablecontainer,samples,com.ibm.sdk.6_32bit'

websphere_package :was do
  install_fixes :all
  action :install
end

was_dir = lazypath(node[:was][:dir])

template ::File.join(was_dir, 'properties/wasprofile.properties') do
  owner     node[:wpf][:user][:name]
  group     node[:wpf][:user][:group]
  mode      00644
  variables was: node[:was]
end

websphere_package :wps do
  install_fixes :all
  action :install
end
