# encoding: UTF-8

include_recipe 'garcon'
include_recipe 'garcon::development'
include_recipe 'test_fixtures::devreporter'

template '/etc/motd' do
  owner 'root'
  group 'root'
  mode  00644
  notifies :create, 'template[profile]'
  action :create
end

template 'profile' do
  source   'profile.erb'
  path      ::File.join(node[:wpf][:user][:home], '.profile')
  owner     lazy { node[:wpf][:user][:name] }
  group     lazy { node[:wpf][:user][:group] }
  mode      00644
  variables path: ::File.join(lazypath(node[:iim][:dir]), 'tools')
  action :nothing
end
