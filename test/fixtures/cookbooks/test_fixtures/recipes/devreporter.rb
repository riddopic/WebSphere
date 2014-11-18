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
