# encoding: UTF-8
#
# Author: Stefano Harding <riddopic@gmail.com>
# Cookbook Name:: websphere
# Recipe:: default
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

single_include 'garcon::default'

recipe_fork(:spoon) do
  thread(:fork) do
    block do
      %w(hoodie rubyzip).each do |gem_pkg|
        chef_gem(gem_pkg){action :nothing}.run_action(:install)
      end
    end
  end
end

thread(:warm) { block { Chef::Log.info ThreadPool.status }}

require 'securerandom' unless defined?(SecureRandom)
require 'tempfile'     unless defined?(Tempfile)

group node[:websphere][:group] do
  action :create
end

user node[:websphere][:user] do
  comment 'Websphere Application Server'
  gid node[:websphere][:group]
  home node[:websphere][:iim_install_root]
  system true
  action :create
end

%w(gtk2-engines).each { |pkg| package pkg }

multiarch = %w(gtk2 libgcc glibc)

if node[:kernel][:machine] == 'i686'
  multiarch.each { |pkg| yum_package pkg }
else
  archs = node[:platform_version].to_i >= 6 ? %w(x86_64 i686) : %w(x86_64 i386)

  multiarch.each do |pkg|
    archs.each do |arch|
      yum_package pkg do
        arch arch
      end
    end
  end
end

include_recipe 'websphere::_transfer'
