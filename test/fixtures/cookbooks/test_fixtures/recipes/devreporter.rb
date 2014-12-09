# encoding: UTF-8

include_recipe 'chef_handler'

cookbook_file ::File.join(node[:chef_handler][:handler_path], 'devreporter.rb') do
  action :create
  mode 00600
end

chef_handler 'DevReporter' do
  source ::File.join(node[:chef_handler][:handler_path], 'devreporter.rb')
  supports report: true
  action :enable
end

include_recipe 'websphere::default'

template ::File.join(node[:websphere][:user][:home], '.profile') do
  source 'profile.erb'
  owner node[:websphere][:user][:name]
  group node[:websphere][:user][:group]
  mode 00644
  subscribes :create, resources("user[#{node[:websphere][:user][:name]}]")
  not_if { node[:websphere][:user][:username] == 'root' }
  action :nothing
end
