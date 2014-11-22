# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_resource
#

require 'chef/resource/lwrp_base'
require_relative 'websphere_provider'

# A Chef resource for the WebSphere packages
#
class Chef::Resource::Websphere < Chef::Resource::LWRPBase
  self.resource_name = 'websphere'

  actions :install, :uninstall, :modify, :set_credential
  default_action :install

  attribute :name, kind_of: String, name_attribute: true
  attribute :master_password_file, kind_of: String, required: true
  attribute :secure_storage_file, kind_of: String, required: true
  attribute :apps, kind_of: Array
end
