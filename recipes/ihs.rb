# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: ihs
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

single_include 'websphere::install'

websphere_package :ihs do
  install_fixes :none
  action :install
end

template '/etc/init.d/ihs' do
  owner     'root'
  group     'root'
  mode      00754
  variables apachectl: ::File.join(lazypath(node[:ihs][:dir]), 'bin/apachectl')
  notifies  :start, 'service[ihs]'
  action :create
end

service 'ihs' do
  supports status: true, start: true, stop: true, restart: true
  action [:enable, :start]
end
