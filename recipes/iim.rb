# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Recipe:: iim
#

single_include 'websphere::default'

directory node[:websphere][:base_dir] do
  owner node[:websphere][:user][:name]
  group node[:websphere][:user][:group]
  mode 00755
  recursive true
  action :create
end

with_tmp_dir do |tmpdir|
  directory tmpdir do
    owner node[:websphere][:user][:name]
    group node[:websphere][:user][:group]
    mode 00755
    recursive true
    notifies :delete, "directory[#{tmpdir}]"
    action :create
  end

  websphere_package 'iim' do
    install_type :cli
    tmpdir tmpdir
    action [:copy, :unpack, :install]
  end
end

websphere_package 'pkgutil' do
  action :install
end

websphere_credentials :secret do
  sensitive true
  action :store
end

node[:websphere][:apps].each do |app|
  websphere_package app do
    action :install
  end
end
