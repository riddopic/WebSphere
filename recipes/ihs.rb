# encoding: UTF-8
#
# Cookbook Name:: websphere
# Recipe:: ihs
#

single_include 'websphere::default'

was_installer 'ihs' do
  profile_id       'IBM HTTP Server V8.5'
  installer_dir    node[:websphere][:ihs_dir]
  install_location [node[:websphere][:ihs_dir]]
  offering [
    { offering_id:   'com.ibm.websphere.IHSILAN.v85',
      version:       '8.5.5001.20131018_2242',
      profile:       'IBM HTTP Server V8.5',
      features:      'core.feature,arch.64bit',
      install_fixes: 'none' }
  ]
end
