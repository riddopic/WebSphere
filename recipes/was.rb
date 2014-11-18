# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: was
#

single_include 'websphere::default'

was_installer :was do
  profile_id      'IBM WebSphere Application Server V8.5'
  installer_dir    node[:websphere][:websphere_dir]
  install_location node[:websphere][:websphere_installer_dir]
  offering [
    { offering_id:   'com.ibm.websphere.ND.v85',
      version:       '8.5.0.20120501_1108',
      profile:       'IBM WebSphere Application Server V8.5',
      features:      'core.feature,ejbdeploy,thinclient,embeddablecontainer,'\
                     'liberty,samples,com.ibm.sdk.6_64bit',
      install_fixes: 'none' },
    { offering_id:   'com.ibm.websphere.IBMJAVA.v70',
      version:       '7.0.1000.20120424_1539',
      profile:       'IBM WebSphere Application Server V8.5',
      features:      'com.ibm.sdk.7',
      install_fixes: 'none' }
  ]
end

observable_event(:was) do
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
  Chef::Log.info 'thanks for the notify Chuck!'
  Chef::Log.info '------- Ξ ------- 彡 ------- 入 ------- ハ -------'
end
