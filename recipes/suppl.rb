# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: plg
#

single_include 'websphere::default'

was_installer 'plg' do
  profile_id 'Web Server Plug-ins for IBM WebSphere Application Server V8.5_1'
  installer_dir node[:websphere][:plg_dir]
  install_location node[:websphere][:ihs_installer_dir]
  offering [
    {
      offering_id: 'com.ibm.websphere.PLG.v85',
      version: '8.5.0.20120501_1108',
      profile: 'IBM WebSphere Application Server V8.5',
      features: 'core.feature,com.ibm.jre.6_64bit',
      install_fixes: 'none'
    }
  ]
end

observable_event(:suppl) do
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
  Chef::Log.info 'thanks for the notify Chuck!'
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
end
