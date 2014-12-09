# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_credentials_resource
#

# For repositories that require authentication this creates a storage file.
# Once created the use of the -secureStorageFile and -masterPasswordFile
# options to store and retrieve credentials will be avaliable.
#
class Chef::Resource::WebsphereCredentials < Chef::Resource::LWRPBase
  # Chef attributes
  identity_attr :credentials
  provides :websphere_credentials
  state_attrs :stored

  # Set the resource name
  self.resource_name = :websphere_credentials

  # Actionss
  actions :store
  default_action :store

  attribute :username, kind_of: [String, Symbol], name_attribute: true

  # @!attribute [w] name
  #   @return [String] name attribute
  attribute :name,                 kind_of: String,    name_attribute: true

  def owner(arg = nil)
    from_attributes = run_context.node[:websphere][:user][:name]
    from_resource_block = self.instance_variable_get('@owner')

    arg = from_resource_block ||= from_attributes if arg == nil
    set_or_return(:owner, arg, kind_of: String)
  end

  def __set_attribute_value__(arg, attribute_name, kind_of)
    if run_context.node[:websphere].keys.include? attribute_name
      from_attributes = run_context.node[:websphere][attribute_name]
    elsif run_context.node[:websphere][:user].keys.include? attribute_name
      from_attributes = run_context.node[:websphere][:user][attribute_name]
    else
      from_attributes = run_context.node[:websphere][:credential][attribute_name]
    end
    Chef::Log.debug "Default #{attribute_name} is #{from_attributes}"

    from_resource_block = self.instance_variable_get("@#{attribute_name}")
    arg = from_resource_block ||= from_attributes if arg == nil
    Chef::Log.debug "Merged #{attribute_name} is #{arg}"

    set_or_return(attribute_name.to_sym, arg, kind_of: kind_of)
  end

  def master_password_file(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end

  def secure_storage_file(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end

  def username(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end

  def password(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end

  def group(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end

  def url(arg = nil)
     __set_attribute_value__(arg, __method__, String)
  end
end
