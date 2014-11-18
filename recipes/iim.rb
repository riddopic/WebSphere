# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: iim
#

single_include 'websphere::default'

# execute './userinstc -log /tmp/IMinstall.log -acceptLicense' do
#   cwd   node[:websphere][:iim_install_root]
#   user  node[:websphere][:user]
#   group node[:websphere][:group]
# end

# file_name = node[:websphere][:iim][:files][0][:name]

observable_event(:iim) do
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
  Chef::Log.info 'thanks for the notify Chuck!'
  # execute './userinstc -log /tmp/IMinstall.log -acceptLicense' do
  #   cwd   node[:websphere][:iim_install_root]
  #   user  node[:websphere][:user]
  #   group node[:websphere][:group]
  # end
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
end
