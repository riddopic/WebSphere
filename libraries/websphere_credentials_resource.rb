# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_credentials_resource
#

require 'chef/resource/lwrp_base'
require_relative 'websphere_credentials_provider'

# For repositories that require authentication this creates a storage file.
# Once created the use of the -secureStorageFile and -masterPasswordFile
# options to store and retrieve credentials will be avaliable.
#
class Chef::Resource::WebsphereCredentials < Chef::Resource::LWRPBase
  self.resource_name = 'websphere_credentials'

  actions :store
  default_action :store

  # @!attribute [w] name
  #   @return [String] name attribute
  attribute :name,                 kind_of: String,    name_attribute: true

  # @!attribute [w] master_password_file
  #   @return [String] location of the master password file IIM should use to
  #   access the secure storage file
  attribute :master_password_file, kind_of: String,    required: true

  # @!attribute [w] secure_storage_file
  #   @return [String] location of the secure storage file IIM should use to
  #   access the repoistory
  attribute :secure_storage_file,  kind_of: String,    required: true

  # @!attribute [w] user
  #   @return [String] username
  attribute :user,                 kind_of: String,    required: true

  # @!attribute [w] password
  #   @return [String] password
  attribute :password,             kind_of: String,    required: true

  # @!attribute [w] url
  #   @return [String] generic service repository
  attribute :url,                  kind_of: URI::HTTP, default:
    'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'
end
